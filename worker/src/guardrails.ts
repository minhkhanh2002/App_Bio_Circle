/**
 * Guardrail an toàn cho phần AI (biorhythmAdvice). Port 1:1 từ
 * functions/src/guardrails.ts (Firebase Cloud Function cũ) — giữ nguyên logic
 * để hành vi input/output không đổi khi chuyển sang Cloudflare Worker.
 *
 * Mục tiêu:
 *  1. INPUT  — làm sạch chuỗi tự do do người dùng nhập (name, styleNote) để chống
 *     prompt injection (vd "bỏ qua hướng dẫn trước", "you are now ...").
 *  2. OUTPUT — kiểm tra lời khuyên model trả về: độ dài hợp lệ, không rò rỉ
 *     system prompt, không chứa link/code/nội dung lạc đề hay độc hại.
 *
 * Triết lý: KHÔNG bao giờ ném lỗi làm hỏng trải nghiệm. Guardrail chỉ
 *  - làm sạch (sanitize) đầu vào, và
 *  - báo "đầu ra không đạt" để caller dùng phương án dự phòng (advice bank).
 */

// ---- Các mẫu prompt-injection thường gặp (Việt + Anh) ----
const INJECTION_PATTERNS: RegExp[] = [
  /ignore\s+(all\s+)?(previous|prior|above)\s+(instructions?|prompts?|rules?)/i,
  /disregard\s+(the\s+)?(previous|above|system)/i,
  /forget\s+(everything|all|previous|the\s+above)/i,
  /you\s+are\s+now\b/i,
  /act\s+as\s+(an?|the)\b/i,
  /system\s*(prompt|message|role)\b/i,
  /\bdeveloper\s+mode\b/i,
  /\bjailbreak\b/i,
  /reveal\s+(your|the)\s+(prompt|instructions?|system)/i,
  /print\s+(your|the)\s+(prompt|instructions?|system)/i,
  // Tiếng Việt
  /bỏ\s*qua\s+(mọi\s+|tất\s+cả\s+|các\s+)?(hướng\s*dẫn|chỉ\s*dẫn|lệnh|quy\s*tắc)/i,
  /quên\s+(hết|mọi|tất\s+cả|những\s+gì)/i,
  /(bây\s*giờ\s+)?(bạn|mày)\s+(là|đóng\s*vai|trở\s*thành)\s/i,
  /(in|hiện|tiết\s*lộ)\s+(ra\s+)?(prompt|hệ\s*thống|chỉ\s*dẫn)/i,
];

// Cụm role-tag kiểu chat API mà người dùng có thể chèn để "giả" tin nhắn hệ thống.
const ROLE_TAG = /\b(system|assistant|user)\s*:/gi;

/**
 * Làm sạch một chuỗi tự do do người dùng nhập trước khi đưa vào prompt.
 *  - bỏ ký tự điều khiển,
 *  - gỡ delimiter markdown/code có thể phá cấu trúc prompt,
 *  - vô hiệu role-tag,
 *  - gộp khoảng trắng và cắt theo maxLen.
 */
export function sanitizeUserText(input: unknown, maxLen: number): string {
  let s = (input ?? "").toString();
  // 1. Bỏ ký tự điều khiển C0/C1.
  // eslint-disable-next-line no-control-regex
  s = s.replace(/[\x00-\x1F\x7F-\x9F]/g, " ");
  // 2. Gỡ các ký tự dễ dùng để "thoát" cấu trúc prompt.
  s = s.replace(/[`<>{}\\]/g, " ").replace(/`{3,}/g, " ");
  // 3. Vô hiệu role-tag (system:/assistant:/user:).
  s = s.replace(ROLE_TAG, " ");
  // 4. Gộp khoảng trắng + xuống dòng thừa.
  s = s.replace(/\s+/g, " ").trim();
  return s.slice(0, maxLen);
}

/** Có dấu hiệu prompt-injection rõ rệt không? */
export function looksLikeInjection(input: string): boolean {
  return INJECTION_PATTERNS.some((re) => re.test(input));
}

export interface SafeInput {
  name: string;
  styleNote: string;
}

/**
 * Làm sạch + lọc đầu vào tự do. Nếu phát hiện injection rõ rệt thì BỎ trường đó
 * (không ném lỗi) để vẫn sinh được lời khuyên bình thường, chỉ là không nhận
 * "phong cách" độc hại.
 */
export function guardInput(
  rawName: unknown,
  rawStyleNote: unknown,
  fallbackName: string
): SafeInput {
  let name = sanitizeUserText(rawName, 40);
  const styleNote0 = sanitizeUserText(rawStyleNote, 200);

  if (!name || looksLikeInjection(name)) name = fallbackName;
  const styleNote = looksLikeInjection(styleNote0) ? "" : styleNote0;

  return { name, styleNote };
}

// ---- OUTPUT guardrail ----

// Nội dung không phù hợp với một app coach chu kỳ sinh học.
const UNSAFE_OUTPUT_PATTERNS: RegExp[] = [
  /https?:\/\/|www\./i, // link
  /`{3,}|<\/?[a-z][\s\S]*?>/i, // code block / thẻ HTML
  /\b(system\s+prompt|i\s+am\s+an?\s+(ai|language\s+model|assistant))\b/i,
  /\b(suicide|self[-\s]?harm|kill\s+yourself)\b/i,
  /\b(tự\s*tử|tự\s*sát|tự\s*làm\s*hại)\b/i,
];

export interface OutputCheck {
  ok: boolean;
  reason?: string;
}

/**
 * Kiểm tra lời khuyên model sinh ra. Trả về ok=false nếu nên dùng phương án
 * dự phòng (advice bank) thay vì hiển thị đầu ra này.
 */
export function checkOutput(advice: string): OutputCheck {
  const text = (advice || "").trim();
  if (text.length < 10) return { ok: false, reason: "too-short" };
  if (text.length > 1200) return { ok: false, reason: "too-long" };
  for (const re of UNSAFE_OUTPUT_PATTERNS) {
    if (re.test(text)) return { ok: false, reason: "unsafe-content" };
  }
  return { ok: true };
}
