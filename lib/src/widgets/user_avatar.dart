import 'package:app/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final String? initials;
  final Widget? cover;
  final bool showHolder;

  UserAvatar({
    Key? key,
    required this.url,
    required this.radius,
    required String? initials,
    this.showHolder = true,
    this.cover,
  })  : initials = initials?.initials(),
        super(key: key);

  Color get backgroundColor => Color(initials.hashCode * 6).withOpacity(1);

  @override
  Widget build(BuildContext context) {
    final holder = !showHolder
        ? null
        : initials.isNullOrEmpty
            ? Icon(
                CupertinoIcons.person,
                size: radius,
                color: context.theme.textTheme.caption?.color,
              )
            : Padding(
                padding: EdgeInsets.only(top: 1.5),
                child: Text(
                  initials.orDefault(),
                  style: context.theme.textTheme.subtitle2?.copyWith(
                    fontSize: radius * 0.75,
                    color: backgroundColor.brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              );

    return url.isNullOrEmpty
        ? _container(context, holder: holder)
        : CachedNetworkImage(
            imageBuilder: (context, imageProvider) =>
                _container(context, imageProvider: imageProvider),
            errorWidget: (context, url, error) =>
                _container(context, holder: holder),
            imageUrl: url!,
            placeholder: (context, string) =>
                _container(context, holder: holder),
          );
  }

  Widget _container(BuildContext context,
          {ImageProvider? imageProvider, Widget? holder}) =>
      ClipOval(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          color: holder == null || initials.isNullOrEmpty
              ? context.theme.dividerColor
              : backgroundColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (holder != null) Center(child: holder),
              if (imageProvider != null)
                Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              if (cover != null) cover!,
            ],
          ),
        ),
      );
}
