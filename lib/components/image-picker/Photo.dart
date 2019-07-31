import 'package:flutter/material.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';

Future<List<ImageEntity>> pickAsset(context) async {
  return PhotoPicker.pickImage(
    context: context,
    // BuildContext requied

    // The following are optional parameters.
    themeColor: Colors.green,
    // the title color and bottom color
    padding: 1.0,
    // item padding
    dividerColor: Colors.grey,
    // divider color
    disableColor: Colors.grey.shade300,
    // the check box disable color
    itemRadio: 0.88,
    // the content item radio
    maxSelected: 8,
    // max picker image count
    provider: I18nProvider.chinese,
    // i18n provider ,default is chinese. , you can custom I18nProvider or use ENProvider()
    rowCount: 5,
    // item row count
    textColor: Colors.white,
    // text color
    thumbSize: 150,
    // preview thumb size , default is 64
    sortDelegate: SortDelegate.common,
    // default is common ,or you make custom delegate to sort your gallery
    checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
      activeColor: Colors.white,
      unselectedColor: Colors.white,
//      checkColor: Colors.blue,
    ),
    // default is DefaultCheckBoxBuilderDelegate ,or you make custom delegate to create checkbox

//    loadingDelegate: this,
    // if you want to build custom loading widget,extends LoadingDelegate [see example/lib/main.dart]

//    badgeDelegate: const DefaultBadgeDelegate(),

    // or custom class extends [BadgeDelegate]

//    pickType: type,
    // all/image/video

//    List < AssetPathEntity > photoPathList,

    // when [photoPathList] is not null , [pickType] invalid .
  );
}
