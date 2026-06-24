/// Kho lời khuyên sinh sẵn (không tốn phí API).
///
/// Dùng làm lời khuyên MẶC ĐỊNH khi người dùng chưa bấm "Cá nhân hóa bằng AI".
/// Mỗi (chu kỳ × mức) có nhiều biến thể; ghép 3 chu kỳ lại tạo rất nhiều tổ hợp
/// nên không bị lặp. Người dùng có thể bấm "Đổi gợi ý" để xáo biến thể khác.
class AdviceBank {
  /// level: 'high' (>65), 'mid', 'low' (<40)
  static String _level(int pct) => pct > 65 ? 'high' : (pct < 40 ? 'low' : 'mid');

  // Thứ tự đầy đủ; hàm chỉ lấy những chu kỳ có trong metrics (core hoặc extended).
  static const List<String> _order = [
    'physical', 'emotional', 'intellectual',
    'intuition', 'aesthetic', 'awareness', 'spiritual',
  ];

  static String advice({
    required String locale,
    required Map<String, int> metrics,
    required int seed,
  }) {
    final bank = locale == 'en' ? _en : _vi;
    final lines = <String>[];
    var i = 0;
    for (final cycle in _order) {
      if (!metrics.containsKey(cycle)) continue;
      final variants = bank[cycle]![_level(metrics[cycle] ?? 50)]!;
      // Lệch chỉ số theo từng chu kỳ để không trùng index khi xáo.
      final idx = (seed + i) % variants.length;
      lines.add(variants[idx]);
      i++;
    }
    return lines.join('\n');
  }

  static const Map<String, Map<String, List<String>>> _vi = {
    'physical': {
      'high': [
        'Thể lực đang lên đỉnh — tận dụng để vận động mạnh hoặc xử lý việc nặng nhé. 💪',
        'Cơ thể tràn năng lượng hôm nay, rất hợp để thử thách bản thân một chút. 🔥',
        'Sức bền tốt, đừng ngại đẩy cường độ tập luyện lên cao hơn. 🏃',
      ],
      'mid': [
        'Thể trạng ổn định, duy trì thói quen lành mạnh là đủ. 🧘',
        'Sức khỏe ở mức cân bằng — cứ giữ nhịp như mọi ngày. 🌿',
        'Cơ thể bình thường, không cần ép nhưng cũng đừng lơ là vận động. 🚶',
      ],
      'low': [
        'Năng lượng hơi xuống, ưu tiên nghỉ ngơi và ngủ đủ giấc nhé. 🔋',
        'Cơ thể cần được sạc lại — tránh làm quá sức hôm nay. 😴',
        'Hãy nhẹ nhàng với bản thân, chọn vận động nhẹ thay vì gắng sức. 🍃',
      ],
    },
    'emotional': {
      'high': [
        'Tâm trạng đang rất tích cực, hợp để gặp gỡ và kết nối. 🥰',
        'Cảm xúc thăng hoa — chia sẻ niềm vui ấy với người xung quanh đi. ✨',
        'Bạn đang tự tin và cởi mở, thời điểm tốt cho những cuộc trò chuyện ý nghĩa. 💛',
      ],
      'mid': [
        'Cảm xúc cân bằng, tâm trí nhẹ nhàng và dễ chịu. 🧘',
        'Lòng bình ổn hôm nay — một ngày êm để làm việc mình thích. 🌸',
        'Tinh thần ổn định, đủ vững để xử lý mọi việc thường ngày. 🙂',
      ],
      'low': [
        'Hơi nhạy cảm một chút, dành thời gian tĩnh lặng cho riêng mình nhé. 🍵',
        'Cảm xúc dễ chùng xuống — nghe nhạc hoặc đi dạo sẽ giúp ích. 🎧',
        'Hãy nhẹ nhàng với cảm xúc của mình, không cần ép vui hôm nay. 🌙',
      ],
    },
    'intellectual': {
      'high': [
        'Đầu óc đang rất sắc bén, tận dụng để học hay giải quyết việc khó. 🧠',
        'Tư duy nhạy bén hôm nay — hợp để lên kế hoạch hoặc sáng tạo. 💡',
        'Khả năng tập trung cao, đây là lúc lý tưởng cho công việc cần não. 📚',
      ],
      'mid': [
        'Trí lực ổn định, xử lý công việc đều tay là được. 💼',
        'Tư duy ở mức tốt vừa phải — chia việc hợp lý sẽ hiệu quả. 🗂️',
        'Đầu óc tỉnh táo bình thường, cứ tiến hành như dự định. ✅',
      ],
      'low': [
        'Khó tập trung hơn chút, nên để việc quan trọng lại sau. ☕',
        'Não cần nghỉ — tránh quyết định lớn và chia nhỏ công việc ra. 🧩',
        'Hôm nay tư duy hơi chậm, ưu tiên việc nhẹ và thư giãn tinh thần. 🌼',
      ],
    },
    'intuition': {
      'high': [
        'Trực giác đang rất nhạy — tin vào linh cảm đầu tiên của bạn nhé. 🔮',
        'Giác quan thứ sáu lên cao, hợp để ra quyết định theo cảm nhận. ✨',
      ],
      'mid': [
        'Trực giác ở mức bình thường, cứ cân nhắc thêm lý trí cho chắc. 🧭',
        'Linh cảm tạm ổn — nghe theo nhưng vẫn kiểm chứng một chút. 🙂',
      ],
      'low': [
        'Cảm nhận chưa rõ ràng, nên hỏi thêm ý kiến khách quan. 🧩',
        'Trực giác hơi mờ hôm nay, đừng vội tin cảm tính. 🌫️',
      ],
    },
    'aesthetic': {
      'high': [
        'Cảm quan nghệ thuật thăng hoa — hợp để sáng tạo hoặc thưởng thức cái đẹp. 🎨',
        'Gu thẩm mỹ đang rất tốt, thử làm điều gì đó đẹp đẽ đi. 🖼️',
      ],
      'mid': [
        'Khả năng cảm thụ ở mức ổn định, nhẹ nhàng và dễ chịu. 🌸',
        'Thẩm mỹ bình thường — vẫn đủ tinh tế cho việc thường ngày. 🌿',
      ],
      'low': [
        'Cảm hứng sáng tạo hơi chững, thư giãn để nạp lại nhé. 🍃',
        'Hôm nay khó "bắt sóng" cái đẹp, đừng ép sáng tạo. 🌙',
      ],
    },
    'awareness': {
      'high': [
        'Khả năng tự nhận thức rất tốt — hợp để chiêm nghiệm và học hỏi. 🌟',
        'Bạn đang rất tỉnh thức, thời điểm tốt để nhìn lại bản thân. 🧘',
      ],
      'mid': [
        'Nhận thức cân bằng, đủ vững để tiếp thu điều mới. ✅',
        'Đầu óc tỉnh táo vừa phải — học từ tốn sẽ hiệu quả. 📖',
      ],
      'low': [
        'Hơi mơ hồ về bản thân, bình tâm suy ngẫm và tránh tiêu cực. 🕯️',
        'Nhận thức chưa sắc, để các quyết định lớn lại sau nhé. 🌫️',
      ],
    },
    'spiritual': {
      'high': [
        'Năng lượng tinh thần dồi dào, tràn yêu thương và kết nối sâu sắc. 🌌',
        'Tâm hồn đang an và đầy — hợp để thiền hoặc ở bên người thương. 🕊️',
      ],
      'mid': [
        'Đời sống tinh thần cân bằng, nhẹ nhàng và tự tại. 🧘',
        'Tâm trí thư thái vừa đủ — giữ sự an yên này nhé. 🌿',
      ],
      'low': [
        'Tinh thần hơi uể oải, thử thiền hoặc nghe nhạc nhẹ để nạp lại. 🎧',
        'Năng lượng bên trong xuống thấp, dành thời gian nghỉ ngơi cho tâm hồn. 🌙',
      ],
    },
  };

  static const Map<String, Map<String, List<String>>> _en = {
    'physical': {
      'high': [
        'Your physical energy is peaking — make the most of it with a solid workout or heavy tasks. 💪',
        'Your body is full of energy today; a great time to push yourself a little. 🔥',
        'Strong stamina — don’t hesitate to dial up the training intensity. 🏃',
      ],
      'mid': [
        'Steady physical condition — keeping up your healthy routine is enough. 🧘',
        'Health is balanced; just keep your usual rhythm. 🌿',
        'Body feels normal — no need to push, but don’t skip moving either. 🚶',
      ],
      'low': [
        'Energy is a bit low; prioritize rest and good sleep. 🔋',
        'Your body needs recharging — avoid overexertion today. 😴',
        'Be gentle with yourself; choose light movement over hard effort. 🍃',
      ],
    },
    'emotional': {
      'high': [
        'Your mood is bright — perfect for meeting people and connecting. 🥰',
        'Emotions are soaring; share that joy with those around you. ✨',
        'You’re confident and open — a good time for meaningful conversations. 💛',
      ],
      'mid': [
        'Balanced emotions, a calm and easy mind. 🧘',
        'A settled heart today — a gentle day to do what you love. 🌸',
        'Steady spirits, solid enough for everyday matters. 🙂',
      ],
      'low': [
        'A little sensitive today; carve out some quiet time for yourself. 🍵',
        'Emotions may dip — music or a walk will help. 🎧',
        'Be kind to your feelings; no need to force cheerfulness today. 🌙',
      ],
    },
    'intellectual': {
      'high': [
        'Your mind is razor-sharp — use it to learn or tackle hard problems. 🧠',
        'Sharp thinking today — great for planning or creative work. 💡',
        'High focus; an ideal time for brain-heavy tasks. 📚',
      ],
      'mid': [
        'Steady mental power — handle work at an even pace. 💼',
        'Thinking is decently good — split tasks sensibly for efficiency. 🗂️',
        'Clear-headed as usual; go ahead as planned. ✅',
      ],
      'low': [
        'A bit harder to focus; save important work for later. ☕',
        'Your brain needs a break — avoid big decisions and chunk tasks. 🧩',
        'Thinking is slower today; favor light work and mental rest. 🌼',
      ],
    },
    'intuition': {
      'high': [
        'Your intuition is sharp — trust your first instinct today. 🔮',
        'A strong sixth sense; good for decisions made on feel. ✨',
      ],
      'mid': [
        'Intuition is average — pair it with a bit of reasoning. 🧭',
        'Decent gut feeling; follow it, but verify a little. 🙂',
      ],
      'low': [
        'Your sense isn’t clear; seek an objective opinion. 🧩',
        'Intuition is hazy today — don’t rush on gut alone. 🌫️',
      ],
    },
    'aesthetic': {
      'high': [
        'Artistic senses are soaring — create or enjoy beauty. 🎨',
        'Great taste today; try making something lovely. 🖼️',
      ],
      'mid': [
        'Steady aesthetic sense, gentle and pleasant. 🌸',
        'Normal taste — refined enough for everyday things. 🌿',
      ],
      'low': [
        'Creative spark has slowed; relax to recharge it. 🍃',
        'Hard to feel beauty today — don’t force creativity. 🌙',
      ],
    },
    'awareness': {
      'high': [
        'Strong self-awareness — great for reflection and learning. 🌟',
        'You’re very mindful; a good time to look inward. 🧘',
      ],
      'mid': [
        'Balanced awareness, solid enough to absorb new things. ✅',
        'Reasonably clear-headed — learn at a steady pace. 📖',
      ],
      'low': [
        'A bit unclear about yourself; stay calm and avoid negativity. 🕯️',
        'Awareness is dull; leave big decisions for later. 🌫️',
      ],
    },
    'spiritual': {
      'high': [
        'Abundant spiritual energy, full of love and deep connection. 🌌',
        'Your soul feels calm and full — great for meditation or loved ones. 🕊️',
      ],
      'mid': [
        'A balanced, gentle and serene spiritual life. 🧘',
        'Pleasantly at ease — keep this peace. 🌿',
      ],
      'low': [
        'Spirit feels weary; try meditation or soft music to recharge. 🎧',
        'Inner energy is low — give your soul some rest. 🌙',
      ],
    },
  };
}