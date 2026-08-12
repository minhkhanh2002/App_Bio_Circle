import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app_settings_provider.dart';

/// Bộ chuỗi đa ngôn ngữ (vi/en). Dùng: `final s = AppStrings.of(context);`
/// rồi `s.t('key')`. Gọi trong build() sẽ tự rebuild khi đổi ngôn ngữ.
class AppStrings {
  final String code;
  const AppStrings(this.code);

  bool get isVi => code == 'vi';

  /// Lấy bộ chuỗi và đăng ký rebuild khi ngôn ngữ thay đổi (dùng trong build).
  static AppStrings of(BuildContext context) =>
      AppStrings(context.watch<AppSettingsProvider>().locale.languageCode);

  /// Lấy bộ chuỗi KHÔNG đăng ký rebuild (dùng trong callback ngoài build).
  static AppStrings read(BuildContext context) =>
      AppStrings(context.read<AppSettingsProvider>().locale.languageCode);

  String t(String key) => (isVi ? _vi[key] : _en[key]) ?? key;

  // Chuỗi có tham số
  String date(String d) => isVi ? 'Thời gian: $d' : 'Date: $d';
  String greeting(String name) => isVi ? 'Chào $name!' : 'Hey $name!';
  String cycleDays(int n) => isVi ? 'Chu kỳ $n ngày' : '$n-day cycle';
  String birthdateLabel(String d) => isVi ? 'Ngày sinh: $d' : 'Birth date: $d';
  String chipDays(String name, int n) =>
      isVi ? '$name · $n ngày' : '$name · $n days';

  static const Map<String, String> _vi = {
    // Chung
    'needBirthdate': 'Vui lòng cài đặt ngày sinh trước nhé.',
    'needBirthdateSettings': 'Vui lòng chọn ngày sinh trong cài đặt.',
    'backToToday': 'Về hôm nay',
    'guest': 'bạn',
    // Tên chu kỳ
    'physical': 'Thể chất',
    'emotional': 'Cảm xúc',
    'intellectual': 'Trí tuệ',
    'intuition': 'Trực giác',
    'aesthetic': 'Thẩm mỹ',
    'awareness': 'Nhận thức',
    'spiritual': 'Tinh thần',
    // BottomNav
    'navHome': 'Chính',
    'navExtended': 'Mở rộng',
    'navForecast': 'Dự báo',
    'navSettings': 'Cài đặt',
    // Home
    'home.chartTitle': 'Biểu đồ Chu Kỳ',
    'home.detailTitle': 'Chi tiết chỉ số',
    'home.overallTitle': 'Năng lượng tổng quan',
    'home.overallDesc':
        'Được tính từ trung bình cộng ba chu kỳ thể chất, cảm xúc và trí tuệ ngày hôm nay.',
    'ai.title': 'Gợi ý ngày mới',
    'ai.button': 'Nhận lời khuyên cá nhân hóa',
    'ai.loading': 'Đang tạo...',
    'ai.error': 'Không kết nối được AI, ứng dụng sẽ dùng gợi ý có sẵn bạn nhé.',
    'ai.regenerate': 'Tạo gợi ý khác',
    'ai.personalize': 'Cá nhân hóa bằng AI',
    'ai.shuffle': 'Đổi gợi ý',
    'ai.badge': 'AI',
    'ai.limit': 'Bạn đã dùng lượt gọi AI hôm nay rồi, hẹn mai nhé!',
    'ai.nag2': 'Tôi nghèo lắm nên bạn gọi AI ít thôi nha',
    'ai.nag3': 'Thật đấy, mỗi lần bấm là tôi tốn thêm tiền đó',
    'ai.nag4': 'Huhu tôi sắp phải ăn mì gói cả tháng vì bạn rồi',
    'ai.brokeOwner': 'Tôi đã hết tiền rồi!!! Vui lòng dùng tính năng này sau nhé!',
    'ai.badgeUnlocked': 'Mở khóa huy hiệu ẩn: "Bóc lột người nghèo"! Xem trong Cài đặt nhé',
    // Huy hiệu ẩn
    'badge.section': 'Thành tựu',
    'badge.exploitTitle': 'Bóc lột người nghèo',
    'badge.exploitDesc': 'Cố bấm gọi AI dù tôi đã hết tiền. Một huy hiệu đáng xấu hổ',
    'badge.unlockedTitle': 'THÀNH TỰU ẨN MỚI!',
    'badge.closeBtn': 'Tôi xin lỗi Pio, tôi hứa sẽ bớt bóc lột lại',
    // Thông báo đẩy
    'notif.title': 'Chúc bạn một ngày tốt lành!',
    'settings.notifDenied': 'Bạn cần cấp quyền thông báo để bật tính năng này.',
    'settings.aiStyle': 'Phong cách gợi ý AI',
    'settings.aiStyleNote': 'Ghi chú phong cách (tùy chọn)',
    'settings.aiStyleNoteHint': 'VD: xưng hô thân mật, thêm chút động viên...',
    'style.friendly': 'Thân thiện',
    'style.concise': 'Ngắn gọn',
    'style.humorous': 'Hài hước',
    'style.motivational': 'Truyền cảm hứng',
    'style.professional': 'Chuyên nghiệp',
    'style.poetic': 'Bay bổng',
    'status.peak': 'Đỉnh cao phong độ!',
    'status.low': 'Cần sạc pin gấp',
    'status.balanced': 'Cân bằng',
    'home.physical.high':
        'Thể lực sung mãn, rất thích hợp cho các hoạt động thể lực và thể thao.',
    'home.physical.low':
        'Cơ thể mệt mỏi, hãy nghỉ ngơi nhiều hơn và tránh vận động quá sức.',
    'home.physical.mid':
        'Sức khỏe ổn định, duy trì lối sống lành mạnh như thường ngày.',
    'home.emotional.high':
        'Tâm trạng thăng hoa và tự tin. Rất lý tưởng để giao lưu, gắn kết.',
    'home.emotional.low':
        'Cảm xúc nhạy cảm và dễ căng thẳng. Hãy dành thời gian nghỉ ngơi thư giãn.',
    'home.emotional.mid':
        'Cảm xúc bình ổn, tâm trí nhẹ nhàng, cân bằng tốt.',
    'home.intellectual.high':
        'Trí óc nhạy bén, rất tốt để lên ý tưởng mới hoặc học kỹ năng mới.',
    'home.intellectual.low':
        'Khả năng tập trung giảm, nên để đầu óc thư giãn trước khi đưa ra quyết định lớn.',
    'home.intellectual.mid':
        'Tư duy ổn định, xử lý công việc hiệu quả và logic.',
    // Extend
    'extend.title': 'Chu kỳ Mở rộng',
    'extend.chartTitle': 'Biểu đồ Mở rộng',
    'extend.detailTitle': 'Chi tiết chỉ số',
    'extend.soulTitle': 'Chỉ số trực giác & tâm hồn',
    'extend.soul.high': 'Mức độ nhạy bén nội tâm cực cao!',
    'extend.soul.low': 'Nên hướng về bên trong và dành thời gian nghỉ ngơi.',
    'extend.soul.mid': 'Năng lượng nội tâm ở trạng thái cân bằng.',
    'extend.intuition.high':
        'Trực giác cực kỳ nhạy bén. Hãy tin vào giác quan thứ sáu của bạn hôm nay!',
    'extend.intuition.low':
        'Trực giác chưa rõ ràng, hãy tham khảo thêm ý kiến khách quan từ người xung quanh.',
    'extend.intuition.mid':
        'Trực giác ở mức bình thường, cân nhắc kỹ trước khi quyết định.',
    'extend.aesthetic.high':
        'Cảm hứng nghệ thuật thăng hoa. Thích hợp để sáng tạo, thiết kế hoặc thưởng thức cái đẹp!',
    'extend.aesthetic.low':
        'Cảm hứng nghệ thuật hơi chững lại, hãy thư giãn đầu óc để tìm kiếm ý tưởng mới.',
    'extend.aesthetic.mid':
        'Khả năng cảm thụ thẩm mỹ ở mức ổn định, bình thường.',
    'extend.awareness.high':
        'Khả năng tự nhận thức rất tốt, thích hợp để chiêm nghiệm bản thân và cuộc sống.',
    'extend.awareness.low':
        'Đôi khi thấy hơi mơ hồ về bản thân, hãy bình tâm suy ngẫm và tránh suy nghĩ tiêu cực.',
    'extend.awareness.mid':
        'Độ nhận thức ở mức cân bằng, tự tin vào chính mình.',
    'extend.spiritual.high':
        'Năng lượng tinh thần dồi dào, tràn ngập tình yêu thương và sự kết nối tâm hồn sâu sắc.',
    'extend.spiritual.low':
        'Tinh thần hơi uể oải, hãy thiền hoặc nghe nhạc nhẹ để nạp lại năng lượng bên trong.',
    'extend.spiritual.mid':
        'Đời sống tinh thần cân bằng, nhẹ nhàng và tự tại.',
    // Forecast
    'forecast.title': 'Dự báo 60 ngày tới',
    'forecast.subtitle': 'Những cột mốc đáng chú ý sắp tới của bạn.',
    'forecast.goldenTitle': 'Giai Đoạn Hoàng Kim',
    'forecast.goldenDesc':
        'Đây là lúc năng lượng của bạn — cả thể chất, cảm xúc lẫn trí tuệ — cùng lên đỉnh. Rất hợp để bắt đầu dự án mới, thi cử hay đưa ra quyết định lớn!',
    'forecast.healingTitle': 'Giai Đoạn Phục Hồi',
    'forecast.healingDesc':
        'Đây là lúc năng lượng chung của bạn đang xuống thấp. Đừng ôm đồm quá nhiều việc, hãy dành thời gian chăm sóc bản thân nhiều hơn nhé.',
    'forecast.extremesTitle': 'Những ngày đáng chú ý',
    'forecast.bestPhysical': 'Ngày sung sức nhất',
    'forecast.bestPhysical.tip':
        'Đây là lúc bạn khoẻ nhất trong 60 ngày tới — tranh thủ vận động mạnh hay dồn sức cho việc nặng nhé!',
    'forecast.worstPhysical': 'Ngày cần nghỉ ngơi',
    'forecast.worstPhysical.tip':
        'Cơ thể bạn sẽ hơi đuối vào ngày này — ưu tiên ngủ đủ giấc, đừng ép bản thân quá sức nhé.',
    'forecast.bestEmotional': 'Ngày cảm xúc thăng hoa',
    'forecast.bestEmotional.tip':
        'Tâm trạng bạn sẽ cực kỳ tích cực — hợp để gặp gỡ bạn bè hay bắt đầu điều gì đó mới mẻ!',
    'forecast.worstEmotional': 'Ngày cảm xúc nhạy cảm',
    'forecast.worstEmotional.tip':
        'Bạn có thể thấy dễ bồn chồn hoặc căng thẳng hơn — thử thiền hay nghe vài bản nhạc nhẹ để dịu lại nhé.',
    'forecast.bestIntellectual': 'Ngày đầu óc minh mẫn',
    'forecast.bestIntellectual.tip':
        'Đầu óc bạn sẽ cực kỳ tỉnh táo — thời điểm lý tưởng để học điều mới hay giải quyết việc khó.',
    'forecast.worstIntellectual': 'Ngày dễ mất tập trung',
    'forecast.worstIntellectual.tip':
        'Trí óc bạn có thể hơi khó tập trung hôm nay — chia nhỏ công việc ra để đỡ ngợp nhé.',
    // Settings
    'settings.title': 'Cài đặt',
    'settings.subtitle': 'Quản lý hồ sơ cá nhân và cấu hình ứng dụng.',
    'settings.profile': 'Thông tin cá nhân',
    'settings.app': 'Ứng dụng',
    'settings.feedback': 'Phản hồi',
    'settings.fullName': 'Họ và tên',
    'settings.chooseBirthdate': 'Chọn ngày sinh',
    'settings.dailyNotif': 'Thông báo hàng ngày',
    'settings.notifTime': 'Thời gian thông báo',
    'settings.darkMode': 'Chế độ tối',
    'settings.language': 'Ngôn ngữ',
    'settings.feedbackHint':
        'Ý kiến đóng góp của bạn sẽ giúp ứng dụng ngày càng tốt hơn...',
    'settings.autoSaved': 'Đã tự động lưu ✓',
    'settings.sendFeedback': 'Gửi phản hồi',
    'settings.feedbackSent': 'Cảm ơn phản hồi của bạn! ✓',
    'settings.feedbackEmpty': 'Vui lòng nhập nội dung góp ý.',
    'settings.feedbackEmailInvalid': 'Email không hợp lệ, vui lòng kiểm tra lại.',
    'settings.feedbackError': 'Gửi thất bại, vui lòng thử lại sau.',
    'settings.feedbackQueued': 'Đã lưu — sẽ tự gửi khi có mạng. ✓',
    'settings.feedbackEmailHint': 'Email để chúng tôi phản hồi (tùy chọn)',
    'settings.feedbackAnon': 'Góp ý được gửi ẩn danh.',
    'settings.feedbackOpen': 'Đóng góp ý kiến',
    'settings.feedbackOpenSub': 'Chia sẻ ý kiến giúp ứng dụng tốt hơn',
    'feedback.title': 'Đóng góp ý kiến',
    'feedback.subtitle': 'Mọi ý kiến của bạn đều quý giá với chúng tôi.',
    // Welcome
    'welcome.title': 'Chào mừng!',
    'welcome.subtitle':
        'Hãy nhập thông tin để chúng tôi tính toán tần số sinh học của bạn nhé.',
    'welcome.yourName': 'Tên của bạn',
    'welcome.chooseBirthdate': 'Chọn ngày sinh',
    'welcome.continue': 'Tiếp tục',
    'welcome.fillAll': 'Vui lòng nhập đầy đủ thông tin',
    // Onboarding
    'ob.skip': 'Bỏ qua',
    'ob.next': 'Tiếp tục',
    'ob.explore': 'Khám phá ngay',
    'ob.1.title': 'Chu Kỳ Sinh Học Cá Nhân',
    'ob.1.desc':
        'Mỗi ngày đều mang đến những cảm xúc, nguồn năng lượng và khả năng tập trung khác nhau. Ứng dụng này giúp bạn trực quan hóa các chu kỳ sinh học cá nhân thông qua những biểu đồ dễ hiểu và sinh động, từ đó mang đến một góc nhìn thú vị về sự thay đổi của bản thân theo thời gian.',
    'ob.2.title': 'Ba Chu Kỳ Cốt Lõi',
    'ob.2.desc':
        'Dựa trên mô hình Biorhythm truyền thống, ứng dụng hiển thị các chu kỳ như Thể chất, Cảm xúc và Trí tuệ, đồng thời dự báo xu hướng trong tương lai để bạn có thể theo dõi và khám phá.',
    'ob.3.title': 'Chu Kỳ Mở Rộng',
    'ob.3.desc':
        'Biết trước những ngày bạn ở phong độ tốt nhất và cần nghỉ ngơi. Khám phá thêm các chu kỳ nâng cao cho một bức tranh trọn vẹn.',
    'ob.4.title': 'Lưu Ý Khoa Học',
    'ob.4.desc':
        'Lưu ý rằng Biorhythm hiện chưa được khoa học hiện đại chứng minh là có mối liên hệ trực tiếp với hiệu suất, cảm xúc hay sức khỏe của con người. Vì vậy, ứng dụng được thiết kế như một công cụ tham khảo mang tính giải trí và tự quan sát, giúp bạn hiểu bản thân theo một cách mới mẻ và thú vị hơn.',
    'ob.5.title': 'Nguồn Cảm Hứng',
    'ob.5.desc':
        'Hãy xem các chu kỳ như một nguồn cảm hứng để suy ngẫm, lập kế hoạch và ghi nhận những thay đổi trong cuộc sống hằng ngày của bạn. Biết đâu bạn sẽ khám phá được những quy luật thú vị của riêng mình.',
    // Language select
    'lang.title': 'Chọn ngôn ngữ',
    'lang.subtitle': 'Bạn có thể đổi lại bất cứ lúc nào trong Cài đặt.',
    // Info / ý nghĩa chỉ số
    'info.title': 'Ý nghĩa các chỉ số',
    'info.scale':
        'Mỗi chu kỳ dao động theo hình sin và được quy đổi về thang 0–100%. Trên 65% là cao điểm (thuận lợi), dưới 40% là thấp điểm (nên thận trọng), khoảng giữa là ổn định.',
    'info.coreTitle': 'Ba chu kỳ cốt lõi',
    'info.extendedTitle': 'Bốn chu kỳ mở rộng',
    'info.physical.desc': 'Sức mạnh, sức bền và năng lượng thể chất.',
    'info.emotional.desc': 'Tâm trạng, sự nhạy cảm và khả năng sáng tạo.',
    'info.intellectual.desc': 'Tư duy logic, trí nhớ và sự tập trung.',
    'info.intuition.desc': 'Linh cảm, bản năng và giác quan thứ sáu.',
    'info.aesthetic.desc': 'Cảm thụ cái đẹp và năng lực nghệ thuật.',
    'info.awareness.desc': 'Khả năng tự nhận thức và tiếp thu, học hỏi.',
    'info.spiritual.desc': 'Đời sống tinh thần, sự bình an và kết nối nội tâm.',
    'info.note':
        'Lưu ý: Chu kỳ sinh học là mô hình mang tính tham khảo/giải trí, không phải công cụ y khoa.',
    'info.detailIntroTitle': 'Khám phá Chu Kỳ Sinh Học Cá Nhân',
    'info.detailIntroBody':
        'Mỗi ngày đều mang đến những cảm xúc, nguồn năng lượng và khả năng tập trung khác nhau. Ứng dụng này giúp bạn trực quan hóa các chu kỳ sinh học cá nhân thông qua những biểu đồ dễ hiểu và sinh động, từ đó mang đến một góc nhìn thú vị về sự thay đổi của bản thân theo thời gian.\n\nDựa trên mô hình Biorhythm truyền thống, ứng dụng hiển thị các chu kỳ như Thể chất, Cảm xúc và Trí tuệ, đồng thời dự báo xu hướng trong tương lai để bạn có thể theo dõi và khám phá.\n\nLưu ý rằng Biorhythm hiện chưa được khoa học hiện đại chứng minh là có mối liên hệ trực tiếp với hiệu suất, cảm xúc hay sức khỏe của con người. Vì vậy, ứng dụng được thiết kế như một công cụ tham khảo mang tính giải trí và tự quan sát, giúp bạn hiểu bản thân theo một cách mới mẻ và thú vị hơn.\n\nHãy xem các chu kỳ như một nguồn cảm hứng để suy ngẫm, lập kế hoạch và ghi nhận những thay đổi trong cuộc sống hằng ngày của bạn. Biết đâu bạn sẽ khám phá được những quy luật thú vị của riêng mình.',
  };

  static const Map<String, String> _en = {
    'needBirthdate': 'Please set your birth date first.',
    'needBirthdateSettings': 'Please choose your birth date in Settings.',
    'backToToday': 'Back to today',
    'guest': 'there',
    'physical': 'Physical',
    'emotional': 'Emotional',
    'intellectual': 'Intellectual',
    'intuition': 'Intuition',
    'aesthetic': 'Aesthetic',
    'awareness': 'Awareness',
    'spiritual': 'Spiritual',
    'navHome': 'Home',
    'navExtended': 'Extended',
    'navForecast': 'Forecast',
    'navSettings': 'Settings',
    'home.chartTitle': 'Cycle Chart',
    'home.detailTitle': 'Detailed Metrics',
    'home.overallTitle': 'Overall vitality',
    'home.overallDesc':
        'Calculated from the average of today’s physical, emotional and intellectual cycles.',
    'ai.title': 'Advice',
    'ai.button': 'Get personalized advice',
    'ai.loading': 'Generating...',
    'ai.error': 'Couldn’t generate AI advice, showing a built-in suggestion.',
    'ai.regenerate': 'Generate another',
    'ai.personalize': 'Personalize with AI',
    'ai.shuffle': 'Shuffle suggestion',
    'ai.badge': 'AI',
    'ai.limit': 'You’ve already used your AI call today, see you tomorrow!',
    'ai.nag2': 'I’m quite short on cash, so please limit your use of AI calls.',
    'ai.nag3': 'Seriously, every tap costs me real money',
    'ai.nag4': 'Boohoo, I will be eating instant noodles all month because of you',
    'ai.brokeOwner': 'I’ve run out of money! Please try this feature later!',
    'ai.badgeUnlocked': '🏆 Hidden badge unlocked: “Exploiting the Poor”! Check Settings ',
    // Hidden badge
    'badge.section': 'Achievements',
    'badge.exploitTitle': 'Exploiting the Poor',
    'badge.exploitDesc': 'Kept tapping AI after the owner went broke. A shameful honor',
    'badge.unlockedTitle': 'NEW HIDDEN ACHIEVEMENT!',
    'badge.closeBtn': 'I\'m sorry Pio, I\'ll exploit less',
    // Push notification
    'notif.title': 'Wishing you a wonderful day!',
    'settings.notifDenied': 'You need to grant notification permission to enable this.',
    'settings.aiStyle': 'AI advice style',
    'settings.aiStyleNote': 'Style note (optional)',
    'settings.aiStyleNoteHint': 'e.g. casual tone, add encouragement...',
    'style.friendly': 'Friendly',
    'style.concise': 'Concise',
    'style.humorous': 'Humorous',
    'style.motivational': 'Motivational',
    'style.professional': 'Professional',
    'style.poetic': 'Poetic',
    'status.peak': 'Peak performance!',
    'status.low': 'Time to recharge',
    'status.balanced': 'Balanced',
    'home.physical.high':
        'Great physical condition — ideal for high-intensity sports.',
    'home.physical.low':
        'Your body feels tired. Rest more and avoid overexertion.',
    'home.physical.mid':
        'Stable health — keep up your usual healthy lifestyle.',
    'home.emotional.high':
        'Uplifted and confident mood. Perfect for socializing and bonding.',
    'home.emotional.low':
        'Feeling rather sensitive and prone to stress. Take some quiet time to relax.',
    'home.emotional.mid':
        'Steady emotions, a calm and well-balanced mind.',
    'home.intellectual.high':
        'Razor-sharp mind — great for brainstorming or learning new skills.',
    'home.intellectual.low':
        'Focus is down. Let your brain rest before big decisions.',
    'home.intellectual.mid':
        'Steady mental power — efficient and logical at work.',
    'extend.title': 'Extended Cycles ',
    'extend.chartTitle': 'Extended Chart',
    'extend.detailTitle': 'Detailed Metrics',
    'extend.soulTitle': 'Intuition & soul index',
    'extend.soul.high': 'Extremely high inner sensitivity!',
    'extend.soul.low': 'Turn inward and rest a little more.',
    'extend.soul.mid': 'Your soul frequency is balanced.',
    'extend.intuition.high':
        'Your intuition is razor-sharp. Trust your sixth sense today!',
    'extend.intuition.low':
        'Your sense isn’t clear yet — listen to objective opinions from others.',
    'extend.intuition.mid':
        'Intuition is average — think carefully before deciding.',
    'extend.aesthetic.high':
        'Artistic senses are soaring. Perfect for creating, designing or enjoying beauty!',
    'extend.aesthetic.low':
        'Creativity has slowed a bit — relax your mind to find fresh inspiration.',
    'extend.aesthetic.mid':
        'Your aesthetic sense is stable and steady.',
    'extend.awareness.high':
        'Strong self-awareness — great for reflecting on yourself and life.',
    'extend.awareness.low':
        'You may feel a bit unclear about yourself. Stay calm, reflect and avoid negativity.',
    'extend.awareness.mid':
        'Balanced awareness — confident in yourself.',
    'extend.spiritual.high':
        'Abundant spiritual energy, full of love and deep soul connection.',
    'extend.spiritual.low':
        'Spirit feels a bit weary. Meditate or play soft music to recharge within.',
    'extend.spiritual.mid':
        'A balanced, gentle and serene spiritual life.',
    'forecast.title': 'Next 60 Days Forecast',
    'forecast.subtitle': 'The milestones ahead worth knowing about.',
    'forecast.goldenTitle': 'Golden Period',
    'forecast.goldenDesc':
        'This is when your energy — physical, emotional and intellectual — all peak together. Great for starting new projects, exams or big decisions!',
    'forecast.healingTitle': 'Recovery Period',
    'forecast.healingDesc':
        'This is when your overall energy dips. Don’t overload yourself with work — take some extra time to rest and recharge.',
    'forecast.extremesTitle': 'Days worth noting',
    'forecast.bestPhysical': 'Your strongest day',
    'forecast.bestPhysical.tip':
        'You’ll be at your peak physically — perfect for intense activity or tackling something demanding.',
    'forecast.worstPhysical': 'A day to rest',
    'forecast.worstPhysical.tip':
        'Your body may feel a bit worn out — prioritize sleep and go easy on yourself.',
    'forecast.bestEmotional': 'Your most uplifted day',
    'forecast.bestEmotional.tip':
        'You’ll be brimming with positive energy — great for connecting with people or starting something new.',
    'forecast.worstEmotional': 'A more sensitive day',
    'forecast.worstEmotional.tip':
        'You might feel a bit restless or on edge — try meditating or putting on some relaxing music.',
    'forecast.bestIntellectual': 'Your sharpest day',
    'forecast.bestIntellectual.tip':
        'Your mind will be razor-sharp — a great time to learn something new or tackle a tough problem.',
    'forecast.worstIntellectual': 'A day to slow down',
    'forecast.worstIntellectual.tip':
        'Focus may not come easily today — break your work into smaller chunks so it feels less overwhelming.',
    'settings.title': 'Settings',
    'settings.subtitle': 'Manage your profile and app preferences.',
    'settings.profile': 'Personal Info',
    'settings.app': 'Application',
    'settings.feedback': 'Feedback',
    'settings.fullName': 'Full name',
    'settings.chooseBirthdate': 'Choose birth date',
    'settings.dailyNotif': 'Daily notifications',
    'settings.notifTime': 'Notification time',
    'settings.darkMode': 'Dark mode',
    'settings.language': 'Language',
    'settings.feedbackHint':
        'Your feedback helps make the app better and better...',
    'settings.autoSaved': 'Saved automatically ✓',
    'settings.sendFeedback': 'Send feedback',
    'settings.feedbackSent': 'Thanks for your feedback! ✓',
    'settings.feedbackEmpty': 'Please enter your feedback.',
    'settings.feedbackEmailInvalid': 'Invalid email, please check again.',
    'settings.feedbackError': 'Failed to send, please try again later.',
    'settings.feedbackQueued': 'Saved — will send automatically when online. ✓',
    'settings.feedbackEmailHint': 'Email for us to reply (optional)',
    'settings.feedbackAnon': 'Feedback is sent anonymously.',
    'settings.feedbackOpen': 'Send us feedback',
    'settings.feedbackOpenSub': 'Share ideas to make the app better',
    'feedback.title': 'Send Feedback',
    'feedback.subtitle': 'Every bit of feedback means a lot to us.',
    'welcome.title': 'Welcome!',
    'welcome.subtitle':
        'Enter your details so we can calculate your biorhythms.',
    'welcome.yourName': 'Your name',
    'welcome.chooseBirthdate': 'Choose birth date',
    'welcome.continue': 'Continue',
    'welcome.fillAll': 'Please fill in all fields',
    'ob.skip': 'Skip',
    'ob.next': 'Continue',
    'ob.explore': 'Explore now',
    'ob.1.title': 'Personal Biorhythms',
    'ob.1.desc':
        'Every day brings different emotions, energy levels, and focus capabilities. This app helps you visualize your personal biorhythm cycles through clear, dynamic charts, offering a fascinating perspective on your own changes over time.',
    'ob.2.title': 'Three Core Cycles',
    'ob.2.desc':
        'Based on the traditional Biorhythm model, the app displays cycles such as Physical, Emotional, and Intellectual, and forecasts future trends for you to track and explore.',
    'ob.3.title': 'Forecast & Extended',
    'ob.3.desc':
        'Know in advance the days you’ll be at your best and when to rest. Explore advanced cycles for the full picture.',
    'ob.4.title': 'Scientific Disclaimer',
    'ob.4.desc':
        'Please note that Biorhythms are not currently proven by modern science to have a direct link with human performance, emotions, or health. Therefore, the app is designed as a tool for reference, self-observation, and entertainment, helping you understand yourself in a fresh and interesting way.',
    'ob.5.title': 'Source of Inspiration',
    'ob.5.desc':
        'Consider these cycles as a source of inspiration to reflect, plan, and note changes in your daily life. Perhaps you will discover interesting patterns of your own.',
    'lang.title': 'Choose language',
    'lang.subtitle': 'You can change this anytime in Settings.',
    'info.title': 'What the metrics mean',
    'info.scale':
        'Each cycle follows a sine wave, mapped to a 0–100% scale. Above 65% is a high point (favorable), below 40% is a low point (be cautious), and in between is stable.',
    'info.coreTitle': 'Three core cycles',
    'info.extendedTitle': 'Four extended cycles',
    'info.physical.desc': 'Strength, stamina and physical energy.',
    'info.emotional.desc': 'Mood, sensitivity and creativity.',
    'info.intellectual.desc': 'Logical thinking, memory and focus.',
    'info.intuition.desc': 'Hunches, instinct and the sixth sense.',
    'info.aesthetic.desc': 'Appreciation of beauty and artistic ability.',
    'info.awareness.desc': 'Self-awareness and the ability to learn.',
    'info.spiritual.desc': 'Spiritual life, inner peace and connection.',
    'info.note':
        'Note: Biorhythm is a model for reference/entertainment, not a medical tool.',
    'info.detailIntroTitle': 'Discover Your Personal Biorhythm',
    'info.detailIntroBody':
        'Every day brings different emotions, energy levels, and focus capabilities. This app helps you visualize your personal biorhythm cycles through clear, dynamic charts, offering a fascinating perspective on your own changes over time.\n\nBased on the traditional Biorhythm model, the app displays cycles such as Physical, Emotional, and Intellectual, and forecasts future trends for you to track and explore.\n\nPlease note that Biorhythms are not currently proven by modern science to have a direct link with human performance, emotions, or health. Therefore, the app is designed as a tool for reference, self-observation, and entertainment, helping you understand yourself in a fresh and interesting way.\n\nConsider these cycles as a source of inspiration to reflect, plan, and note changes in your daily life. Perhaps you will discover interesting patterns of your own.',
  };
}