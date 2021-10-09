import 'package:app/design_system.dart';
import 'package:app/extensions.dart';
import 'package:app/src/resources/local_provider.dart';
import 'package:app/src/vm/profile_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/src/widgets/user_avatar.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage._({Key? key}) : super(key: key);

  static Widget show() => ProfilePage._();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ViewModelState<ProfileViewModel, ProfilePage> {
  Widget build(BuildContext context) {
    return FullScreen(
      padding: EdgeInsets.only(bottom: context.theme.bottomInset),
      appBar: AppBar(elevation: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // todo add my questions
          // todo add my answers
          Observer(builder: (context) {
            return Material(
              elevation: 6,
              color: context.theme.colorScheme.primary,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      UserAvatar(
                        initials: vm.person.value?.nameOrEmail,
                        url: vm.person.value?.photoUrl,
                        radius: 60,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 32.0),
                              child: Text(
                                '${vm.person.value?.getLevel().name}',
                                style: context.theme.textTheme.headline5
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        vm.questionsCount.value.toString(),
                                        style: context.theme.textTheme.headline5
                                            ?.copyWith(color: Colors.white),
                                      ),
                                      Text(
                                        "Вопросов",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(children: [
                                    Text(
                                      vm.answersCount.value.toString(),
                                      style: context.theme.textTheme.headline5
                                          ?.copyWith(color: Colors.white),
                                    ),
                                    Text(
                                      "Ответов",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            );
          }),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Text(
                "Количество бонусов: " +
                    (vm.person.value?.points ?? 0).toString(),
                style: context.theme.textTheme.headline5,
              ),
              SizedBox(height: 16),
              Text(
                "Вы можете обменять ваши бонусы на акции ведущих компаний в приложении ВТБ Мои Инвестиции. Открыть брокерский счёт в нём можно так же легко.",
                style: context.theme.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 64),
              GestureDetector(
                onTap: _launchURL,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Открыть брокерский счёт",
                        style: context.theme.textTheme.headline6?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: VtbColors.blue70),
                      ),
                      Container(
                          height: 64,
                          child: Image.asset("images/vtb_investor.png"))
                    ]),
              )
            ]),
          ),
          Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(14)),
              onPressed: () => vm.logout(),
              icon: Icon(Icons.logout),
              label: Text(
                'Выход'.orDefault(),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL() => LocalProvider.openVtb();
}
