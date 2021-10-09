import 'package:app/extensions.dart';
import 'package:app/src/models/person_models.dart';
import 'package:app/src/resources/local_provider.dart';
import 'package:app/src/ui/home.dart';
import 'package:app/src/vm/profile_vm.dart';
import 'package:app/src/vm/rating_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/src/widgets/user_avatar.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  RatingPage._({Key? key}) : super(key: key);

  static Widget show() => RatingPage._();

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends ViewModelState<RatingViewModel, RatingPage> {
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => ListView.builder(
        itemCount: vm.persons.value.length,
        itemBuilder: (context, index) => PersonRatingWidget(
          item: vm.persons.value[index],
        ),
      ),
    );
  }
}

class PersonRatingWidget extends StatelessWidget {
  final Person item;

  const PersonRatingWidget(
      {Key? key, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Card(
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Observer(
              builder: (context) => Row(
                children: [
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Observer(
                          builder: (context) => Row(
                            children: [
                              UserAvatar(
                                initials: item.nameOrEmail,
                                url: item.photoUrl,
                                radius: 16,
                              ),
                              SizedBox(width: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((item.nameOrEmail)
                                      .orDefault()),
                                  Text(
                                    (item.level).orDefault(),
                                    style: context.theme.textTheme.caption,
                                  ),
                                ],
                              ),
                              SizedBox(width: 8.0),
                              Expanded(child: Text("Рейтинг: " + item.points.toString(), textAlign: TextAlign.right,)),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}