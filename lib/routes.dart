import 'package:flutter/material.dart';
import 'package:unionchat/pages/account/account_list.dart';
import 'package:unionchat/pages/account/forget_question.dart';
import 'package:unionchat/pages/account/forget_question_account.dart';
import 'package:unionchat/pages/account/forgot_help.dart';
import 'package:unionchat/pages/account/forgot_password.dart';
import 'package:unionchat/pages/account/login.dart';
import 'package:unionchat/pages/account/login_scan.dart';
import 'package:unionchat/pages/account/new_pwd.dart';
import 'package:unionchat/pages/account/password_question.dart';
import 'package:unionchat/pages/account/phone_login.dart';
import 'package:unionchat/pages/account/phone_register.dart';
import 'package:unionchat/pages/account/phone_register_complete.dart';
import 'package:unionchat/pages/account/register.dart';
import 'package:unionchat/pages/account/register_all.dart';
import 'package:unionchat/pages/account/register_complete.dart';
import 'package:unionchat/pages/application/city_list.dart';
import 'package:unionchat/pages/application/html.dart';
import 'package:unionchat/pages/application/province_list.dart';
import 'package:unionchat/pages/call/video_call.dart';
import 'package:unionchat/pages/chat/chat_across.dart';
import 'package:unionchat/pages/chat/chat_forward.dart';
import 'package:unionchat/pages/chat/chat_management/chat_complaint.dart';
import 'package:unionchat/pages/chat/chat_management/group_apply_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_card.dart';
import 'package:unionchat/pages/chat/chat_management/group_chat_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_clean_user.dart';
import 'package:unionchat/pages/chat/chat_management/group_invite.dart';
import 'package:unionchat/pages/chat/chat_management/group_kick_out.dart';
import 'package:unionchat/pages/chat/chat_management/group_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_members.dart';
import 'package:unionchat/pages/chat/chat_management/group_no_speaking_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_no_speaking_update.dart';
import 'package:unionchat/pages/chat/chat_management/group_notice.dart';
import 'package:unionchat/pages/chat/chat_management/group_notice_update.dart';
import 'package:unionchat/pages/chat/chat_management/group_set_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_transfer_leader.dart';
import 'package:unionchat/pages/chat/chat_setting.dart';
import 'package:unionchat/pages/chat/chat_talk.dart';
import 'package:unionchat/pages/chat/custom_emoji.dart';
import 'package:unionchat/pages/chat/search_all_message.dart';
import 'package:unionchat/pages/chat/search_friend.dart';
import 'package:unionchat/pages/chat/search_image_page.dart';
import 'package:unionchat/pages/chat/search_my_file.dart';
import 'package:unionchat/pages/chat/search_preview.dart';
import 'package:unionchat/pages/chat/search_self_messaged.dart';
import 'package:unionchat/pages/chat/search_video_page.dart';
import 'package:unionchat/pages/chat/target/target_form.dart';
import 'package:unionchat/pages/chat/target/target_list.dart';
import 'package:unionchat/pages/collect/collect_detail.dart';
import 'package:unionchat/pages/collect/collect_home.dart';
import 'package:unionchat/pages/community/community_create.dart';
import 'package:unionchat/pages/community/community_detail.dart';
import 'package:unionchat/pages/community/community_home.dart';
import 'package:unionchat/pages/community/community_my.dart';
import 'package:unionchat/pages/community/community_trends_list.dart';
import 'package:unionchat/pages/debug/isardata.dart';
import 'package:unionchat/pages/debug/logger_info.dart';
import 'package:unionchat/pages/file_preview.dart';
import 'package:unionchat/pages/friend/friend_add.dart';
import 'package:unionchat/pages/friend/friend_add_face.dart';
import 'package:unionchat/pages/friend/friend_add_group.dart';
import 'package:unionchat/pages/friend/friend_add_group_complete.dart';
import 'package:unionchat/pages/friend/friend_black.dart';
import 'package:unionchat/pages/friend/friend_common_circle.dart';
import 'package:unionchat/pages/friend/friend_common_friend.dart';
import 'package:unionchat/pages/friend/friend_common_group.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/friend/friend_detail_setting.dart';
import 'package:unionchat/pages/friend/friend_group.dart';
import 'package:unionchat/pages/friend/friend_label.dart';
import 'package:unionchat/pages/friend/friend_label_add.dart';
import 'package:unionchat/pages/friend/friend_label_add_complete.dart';
import 'package:unionchat/pages/friend/friend_label_members.dart';
import 'package:unionchat/pages/friend/friend_label_members_update.dart';
import 'package:unionchat/pages/friend/friend_list.dart';
import 'package:unionchat/pages/friend/friend_new_friends.dart';
import 'package:unionchat/pages/friend/friend_search.dart';
import 'package:unionchat/pages/friend/friend_setting.dart';
import 'package:unionchat/pages/friend/friend_setting_label.dart';
import 'package:unionchat/pages/friend/group_list.dart';
import 'package:unionchat/pages/friend/scanpage.dart';
import 'package:unionchat/pages/help/circle/circle_apply_log.dart';
import 'package:unionchat/pages/help/circle/circle_ban.dart';
import 'package:unionchat/pages/help/circle/circle_ban_members.dart';
import 'package:unionchat/pages/help/circle/circle_clean_user.dart';
import 'package:unionchat/pages/help/circle/circle_transfer_leader.dart';
import 'package:unionchat/pages/help/circle/usernumber_list.dart';
import 'package:unionchat/pages/help/routes.dart';
import 'package:unionchat/pages/home.dart';
import 'package:unionchat/pages/mall/vip/mall_growth_value.dart';
import 'package:unionchat/pages/mall/mall_home.dart';
import 'package:unionchat/pages/mall/my_card/mall_my_card.dart';
import 'package:unionchat/pages/mall/my_card/mall_use_card.dart';
import 'package:unionchat/pages/message_menu/add_circle.dart';
import 'package:unionchat/pages/message_menu/personal_card.dart';
import 'package:unionchat/pages/message_menu/red_integral/red_packet_integral.dart';
import 'package:unionchat/pages/message_menu/red_integral/red_packet_integral_detil.dart';
import 'package:unionchat/pages/message_menu/red_integral/red_packet_integral_receive.dart';
import 'package:unionchat/pages/message_menu/red_packet.dart';
import 'package:unionchat/pages/message_menu/red_packet_detil.dart';
import 'package:unionchat/pages/message_menu/red_packet_receive.dart';
import 'package:unionchat/pages/mine/change_condition.dart';
import 'package:unionchat/pages/mine/complain.dart';
import 'package:unionchat/pages/mine/customer_list.dart';
import 'package:unionchat/pages/mine/edit_name.dart';
import 'package:unionchat/pages/mine/edit_self.dart';
import 'package:unionchat/pages/mine/good_number_buy.dart';
import 'package:unionchat/pages/mine/good_number_cash.dart';
import 'package:unionchat/pages/mine/good_number_cash_more.dart';
import 'package:unionchat/pages/mine/good_number_renew.dart';
import 'package:unionchat/pages/mine/level_info.dart';
import 'package:unionchat/pages/mine/mine_home.dart';
import 'package:unionchat/pages/mine/mine_service.dart';
import 'package:unionchat/pages/mine/mine_setting.dart';
import 'package:unionchat/pages/mine/mine_setting_slogan.dart';
import 'package:unionchat/pages/mine/mine_update_account.dart';
import 'package:unionchat/pages/mine/more_function.dart';
import 'package:unionchat/pages/mine/my_points.dart';
import 'package:unionchat/pages/mine/search_user.dart';
import 'package:unionchat/pages/mine/share_page.dart';
import 'package:unionchat/pages/note/note_create_pro.dart';
import 'package:unionchat/pages/note/note_detail_pro.dart';
import 'package:unionchat/pages/note/note_home.dart';
import 'package:unionchat/pages/notfound.dart';
import 'package:unionchat/pages/photo_album/album_add.dart';
import 'package:unionchat/pages/photo_album/album_edit.dart';
import 'package:unionchat/pages/photo_album/album_list.dart';
import 'package:unionchat/pages/photo_album/album_photo.dart';
import 'package:unionchat/pages/photo_album/album_share.dart';
import 'package:unionchat/pages/photo_album/photo_home.dart';
import 'package:unionchat/pages/photo_album/photo_upload.dart';
import 'package:unionchat/pages/question/question_detail.dart';
import 'package:unionchat/pages/question/question_list.dart';
import 'package:unionchat/pages/setting/about_app.dart';
import 'package:unionchat/pages/setting/account_and_safe.dart';
import 'package:unionchat/pages/setting/allow_add_method.dart';
import 'package:unionchat/pages/setting/fast_chat.dart';
import 'package:unionchat/pages/setting/lock/lock_enter.dart';
import 'package:unionchat/pages/setting/lock/lock_update.dart';
import 'package:unionchat/pages/setting/login_device.dart';
import 'package:unionchat/pages/setting/my_card.dart';
import 'package:unionchat/pages/setting/online_state.dart';
import 'package:unionchat/pages/setting/set_email.dart';
import 'package:unionchat/pages/setting/set_new_pwd.dart';
import 'package:unionchat/pages/setting/set_phone.dart';
import 'package:unionchat/pages/setting/setting_home.dart';
import 'package:unionchat/pages/setting/setting_language.dart';
import 'package:unionchat/pages/setting/setting_privacy.dart';
import 'package:unionchat/pages/setting/setting_protocol.dart';
import 'package:unionchat/pages/setting/surveys.dart';
import 'package:unionchat/pages/tabs.dart';
import 'package:unionchat/pages/vip/vip_buy.dart';
import 'package:unionchat/pages/vip/vip_history.dart';
import 'package:unionchat/pages/vip/vip_setting.dart';
import 'package:unionchat/pages/wallet/wallet_home.dart';
import 'package:unionchat/pages/wallet/wallet_usage_record.dart';

import 'pages/chat/chat_management/group_set_manage_update.dart';

class Routes {
  static final Map<String, GlobalKey> _pageKey = <String, GlobalKey>{};

  static Map<String, Widget Function(BuildContext)> routes(GlobalKey? key) {
    Map<String, Widget Function(BuildContext)> routes = {
      IsarData.path: (context) => IsarData(key: key),
      LoggerInfo.path: (context) => LoggerInfo(key: key),
      Tabs.path: (context) => Tabs(key: key),
      Home.path: (context) => Home(key: key),
      VideoCall.path: (context) => VideoCall(key: key),
      //红包
      RedPacketPage.path: (context) => RedPacketPage(key: key),
      RedPacketDetilPage.path: (context) => RedPacketDetilPage(key: key),
      RedPacketReceivePage.path: (context) => RedPacketReceivePage(key: key),
      //积分红包
      RedPacketIntegralPage.path: (context) => RedPacketIntegralPage(key: key),
      RedPacketIntegralDetailPage.path: (context) =>
          RedPacketIntegralDetailPage(key: key),
      RedPacketIntegralReceivePage.path: (context) =>
          RedPacketIntegralReceivePage(key: key),

      //个人名片
      PersonalCardPage.path: (context) => PersonalCardPage(key: key),
      //添加朋友
      AddCirclePages.path: (context) => AddCirclePages(key: key),
      ChangeCondition.path: (context) => ChangeCondition(key: key),

      //账号与安全
      AccountAndSafePage.path: (context) => AccountAndSafePage(key: key),
      AboutAppPage.path: (context) => AboutAppPage(key: key),

      ChatTalk.path: (context) => ChatTalk(key: key),
      ChatComplaint.path: (context) => ChatComplaint(key: key),
      GroupKickOut.path: (context) => GroupKickOut(key: key),
      GroupNotice.path: (context) => GroupNotice(key: key),
      GroupNoticeUpdate.path: (context) => GroupNoticeUpdate(key: key),
      GroupInvite.path: (context) => GroupInvite(key: key),
      GroupMembers.path: (context) => GroupMembers(key: key),
      GroupManage.path: (context) => GroupManage(key: key),
      GroupChatManage.path: (context) => GroupChatManage(key: key),
      GroupNoSpeaking.path: (context) => GroupNoSpeaking(key: key),
      GroupNoSpeakingUpdate.path: (context) => GroupNoSpeakingUpdate(key: key),
      GroupSetManage.path: (context) => GroupSetManage(key: key),
      GroupSetManageUpdate.path: (context) => GroupSetManageUpdate(key: key),
      GroupApplyManage.path: (context) => GroupApplyManage(key: key),
      GroupCard.path: (context) => GroupCard(key: key),
      FriendDetails.path: (context) => FriendDetails(key: key),
      FriendDetailSetting.path: (context) => FriendDetailSetting(key: key),
      FriendSettingLabel.path: (context) => FriendSettingLabel(key: key),
      FriendAdd.path: (context) => FriendAdd(key: key),
      FriendGroup.path: (context) => FriendGroup(key: key),
      FriendNewFriends.path: (context) => FriendNewFriends(key: key),
      FriendBlack.path: (context) => FriendBlack(key: key),
      FriendAddGroup.path: (context) => FriendAddGroup(key: key),
      FriendAddGroupComplete.path: (context) =>
          FriendAddGroupComplete(key: key),
      FriendAddFace.path: (context) => FriendAddFace(key: key),
      FriendSearch.path: (context) => FriendSearch(key: key),
      FriendLabel.path: (context) => FriendLabel(key: key),
      FriendLabelMembers.path: (context) => FriendLabelMembers(key: key),
      FriendLabelAdd.path: (context) => FriendLabelAdd(key: key),
      FriendLabelAddComplete.path: (context) =>
          FriendLabelAddComplete(key: key),
      FriendLabelMembersUpdate.path: (context) =>
          FriendLabelMembersUpdate(key: key),
      ScanPage.path: (context) => ScanPage(key: key),
      CommunityHome.path: (context) => CommunityHome(key: key),
      CommunityCreate.path: (context) => CommunityCreate(key: key),
      CommunityMy.path: (context) => CommunityMy(key: key),
      CommunityDetail.path: (context) => CommunityDetail(key: key),
      NoteHome.path: (context) => NoteHome(key: key),
      SettingHome.path: (context) => SettingHome(key: key),
      Login.path: (context) => Login(key: key),
      PhoneLogin.path: (context) => PhoneLogin(key: key),
      Register.path: (context) => Register(key: key),
      RegisterComplete.path: (context) => RegisterComplete(key: key),
      PhoneRegister.path: (context) => PhoneRegister(key: key),
      PhoneRegisterComplete.path: (context) => PhoneRegisterComplete(key: key),
      ForgotPassword.path: (context) => ForgotPassword(key: key),
      ChatSetting.path: (context) => ChatSetting(key: key),
      FriendSetting.path: (context) => FriendSetting(key: key),
      MineSetting.path: (context) => MineSetting(key: key),
      CityList.path: (context) => CityList(key: key),
      ProvinceList.path: (context) => ProvinceList(key: key),
      MineSettingSlogan.path: (context) => MineSettingSlogan(key: key),
      ChatForward.path: (context) => ChatForward(key: key),
      GoodNumberCashPage.path: (context) => GoodNumberCashPage(key: key),
      LoginDevicePage.path: (context) => LoginDevicePage(key: key),
      OnlineStatePage.path: (context) => OnlineStatePage(key: key),
      SetNewPasswordPage.path: (context) => SetNewPasswordPage(key: key),
      SetPhone.path: (context) => SetPhone(key: key),
      LockEnter.path: (context) => LockEnter(key: key),
      LockUpdate.path: (context) => LockUpdate(key: key),
      SharePage.path: (context) => SharePage(key: key),
      EditSelfPage.path: (context) => EditSelfPage(key: key),
      EditNamePage.path: (context) => EditNamePage(key: key),
      MyCardPage.path: (context) => MyCardPage(key: key),
      MyPointPage.path: (context) => MyPointPage(key: key),
      SearchAllMessagePage.path: (context) => SearchAllMessagePage(key: key),
      SearchSelfMessagesPage.path: (context) =>
          SearchSelfMessagesPage(key: key),
      SearchImagePae.path: (context) => SearchImagePae(key: key),
      SearchVideoPage.path: (context) => SearchVideoPage(key: key),
      SearchMyFilePage.path: (context) => SearchMyFilePage(key: key),

      FilePreview.path: (context) => FilePreview(key: key),
      HtmlPage.path: (context) => HtmlPage(key: key),
      SettingLanguage.path: (context) => SettingLanguage(key: key),
      FriendCommonGroup.path: (context) => FriendCommonGroup(key: key),
      FriendCommonFriend.path: (context) => FriendCommonFriend(key: key),
      FriendCommonCircle.path: (context) => FriendCommonCircle(key: key),
      SettingPrivacy.path: (context) => SettingPrivacy(key: key),
      SettingProtocol.path: (context) => SettingProtocol(key: key),
      CollectHome.path: (context) => CollectHome(key: key),
      CollectDetail.path: (context) => CollectDetail(key: key),
      FastChat.path: (context) => FastChat(key: key),
      MallHome.path: (context) => MallHome(key: key),
      VipBuy.path: (context) => VipBuy(key: key),
      MallMyCard.path: (context) => MallMyCard(key: key),
      LevelInfo.path: (context) => LevelInfo(key: key),
      // SetNameInput.path: (context) => SetNameInput(key: key),
      MallUseCard.path: (context) => MallUseCard(key: key),
      VipSetting.path: (context) => VipSetting(key: key),
      PhotoHome.path: (context) => PhotoHome(key: key),
      AlbumAdd.path: (context) => AlbumAdd(key: key),
      PhotoUpload.path: (context) => PhotoUpload(key: key),
      AlbumList.path: (context) => AlbumList(key: key),
      AlbumPhoto.path: (context) => AlbumPhoto(key: key),
      AlbumEdit.path: (context) => AlbumEdit(key: key),
      VipHistory.path: (context) => VipHistory(key: key),
      MineService.path: (context) => MineService(key: key),
      WalletHome.path: (context) => WalletHome(key: key),
      AlbumShare.path: (context) => AlbumShare(key: key),
      FriendList.path: (context) => FriendList(key: key),
      ChatTargetList.path: (context) => ChatTargetList(key: key),
      ChatTargetForm.path: (context) => ChatTargetForm(key: key),
      WalletUsage.path: (context) => WalletUsage(key: key),
      ChatAcross.path: (context) => ChatAcross(key: key),
      AllowAddMethod.path: (context) => AllowAddMethod(key: key),
      LoginScan.path: (context) => LoginScan(key: key),
      GroupTransferLeader.path: (context) => GroupTransferLeader(key: key),
      MallGrowthValue.path: (context) => MallGrowthValue(key: key),
      CommunityTrendsList.path: (context) => CommunityTrendsList(key: key),
      MineUpdateAccount.path: (context) => MineUpdateAccount(key: key),
      CircleApplyLog.path: (context) => CircleApplyLog(key: key),
      AccountList.path: (context) => AccountList(key: key),
      GoodNumberRenew.path: (context) => GoodNumberRenew(key: key),
      ForgetHelp.path: (context) => ForgetHelp(key: key),
      NewPasswordPage.path: (context) => NewPasswordPage(key: key),
      SearchPreview.path: (context) => SearchPreview(key: key),
      SearchFriend.path: (context) => SearchFriend(key: key),
      CircleBanMembers.path: (context) => CircleBanMembers(key: key),
      CircleTransferLeader.path: (context) => CircleTransferLeader(key: key),

      QuestionList.path: (context) => QuestionList(key: key),
      QuestionDetail.path: (context) => QuestionDetail(key: key),
      PasswordQuestion.path: (context) => PasswordQuestion(key: key),
      ForgetQuestionAccount.path: (context) => ForgetQuestionAccount(key: key),
      ForgetQuestion.path: (context) => ForgetQuestion(key: key),
      CircleBan.path: (context) => CircleBan(key: key),
      Surveys.path: (context) => Surveys(key: key),
      CustomerList.path: (context) => CustomerList(key: key),
      SearchUser.path: (context) => SearchUser(key: key),
      MoreFunction.path: (context) => MoreFunction(key: key),
      Complain.path: (context) => Complain(key: key),
      NoteCreatePro.path: (context) => NoteCreatePro(key: key),
      NoteDetailPro.path: (context) => NoteDetailPro(key: key),
      UserNumberList.path: (context) => UserNumberList(key: key),
      CustomEmoji.path: (context) => CustomEmoji(key: key),
      CircleCleanUser.path: (context) => CircleCleanUser(key: key),
      GroupCleanUser.path: (context) => GroupCleanUser(key: key),
      SetEmail.path: (context) => SetEmail(key: key),
      MineHome.path: (context) => MineHome(key: key),
      RegisterAll.path: (context) => RegisterAll(key: key),
      GoodNumberBuy.path: (context) => GoodNumberBuy(key: key),
      GoodNumberCashPageMore.path: (context) =>
          GoodNumberCashPageMore(key: key),
      GroupList.path: (context) => GroupList(key: key),
    };
    routes.addAll(HelpRoutes.routes(key));
    return routes;
  }

  static GlobalKey? getKey(String path) {
    return _pageKey[path];
  }

  static Widget Function(BuildContext) get(RouteSettings settings) {
    final key = GlobalKey();
    final path = settings.name ?? '';
    final f = routes(key)[path];
    _pageKey[path] = key;
    if (f != null) return f;

    return (context) => const Notfound();
  }
}

class CustomPageTransition extends PageRouteBuilder {
  final Widget page;
  CustomPageTransition({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return Stack(
              children: <Widget>[
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(-0.1, 0.0),
                  ).animate(animation),
                  child: child,
                ),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20.0,
                        ),
                      ],
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.97, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            );
          },
        );
}
