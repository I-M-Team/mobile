import 'dart:io';

import 'package:app/extensions.dart';
import 'package:app/src/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalProvider {
  static openVtb() => launch(vtbUrl());

  static String vtbUrl() {
    return Platform.isIOS
        ? 'https://apps.apple.com/ru/app/id1364026756'
        : 'https://play.google.com/store/apps/details?id=ru.vtb.invest';
  }

  static List<Event> get visibleEvents => events.filter((e) => e.award > 0);

  static List<Event> get invisibleEvents =>
      events.filter((e) => e.award == 0 || e.id == "1");

  static Event? event(String id) {
    return LocalProvider.events.find((e) => e.id == id);
  }

  static final events = [
    Event(
      "1",
      "Привет! Начнем?!",
      "https://www.verslilietuva.lt/wp-content/uploads/2020/04/shutterstock_577166506.jpg",
      "Есть желание инвестировать, но не знаешь с чего начать? Перейди на вкладку \"Задания\", чтобы посмотреть свой текущий прогресс в изучении мира инвестиций и увидеть ближайшие доступные задания.",
      1,
      10,
    ),
    Event(
      "2",
      "Кто я?",
      "https://www.podpisnie.ru/upload/resize_images/21105895/classic_312x460_21105895.jpeg",
      "Пройти опрос на определение уровня знаний в инвестировании.",
      1,
      10,
    ),
    Event(
      "3",
      "Отлично!",
      "https://plusworld.ru/wp-content/uploads/2020/07/172323_or.jpg",
      "Ты выполнил своё первое задание и получил 10 бонусов, бонусы можно тратить на приобретение акций в приложении ВТБ Инвестиции, а так же на различные внутрисервисные действия.",
      1,
      0,
    ),
    Event(
      "4",
      "Выход из тени",
      "https://stihi.ru/pics/2019/03/20/9111.jpg",
      "Заполнить профиль с помощью входа через гугл или просто укажите имя.",
      1,
      15,
    ),
    Event(
      "16",
      "Основа основ",
      "https://yt3.ggpht.com/584JjRp5QMuKbyduM_2k5RlXFqHJtQ0qLIPZpwbUjMJmgzZngHcam5JMuZQxyzGMV5ljwJRl0Q=s900-c-k-c0x00ffffff-no-rj",
      "Узнайте что такое инвестиции и зачем нужно инвестировать посмотрев видео на YouTube",
      1,
      20,
      link: 'https://www.youtube.com/watch?v=-Q6N5jNGo_k',
    ),
    Event(
      "13",
      "Демо",
      "http://2018.goldensite.ru/upload/iblock/c34/c342fd4ce072c97432491efd5e85b3db.png",
      "Открыть демо-счет в ВТБ Инвестиции.",
      1,
      50,
      link: vtbUrl(),
    ),
    Event(
      "15",
      "Первые шаги на бирже",
      "https://school.vtb.ru/upload/resize_cache/iblock/c34/800_800_1/169f0bd31e34ebe9f95457e95147a333.png",
      "Пройдите онлайн-курс от ВТБ за 5 уроков вы узнаете ответы на основные вопросы возникающие у начинающего инвестора",
      1,
      50,
      link: 'https://school.vtb.ru/materials/courses/pervye-shagi-na-birzhe/',
    ),
    Event(
      "5",
      "Отлично!",
      "mascot",
      "Ты перешел на новый уровень, нажми сюда, чтобы посмотреть какой ты в общем рейтинге в этом месяце. Набравшие больше всего рейтинга за неделю, получают 100б, 50б и 10б соответственно занятому месту.",
      1,
      0,
    ),
    Event(
      "6",
      "Первый пошел",
      "https://cs8.pikabu.ru/post_img/big/2016/10/31/7/1477914465176825297.jpg",
      "Задать свой первый вопрос и получить за него лайк.",
      1,
      20,
    ),
    Event(
      "7",
      "Согласовано",
      "https://xn--80aaeffd9darq5b.xn--p1ai/uploads/reksog200.png?1568126661128",
      "Выбрать наилучший ответ на свой вопрос, который больше всего вам помог.",
      1,
      5,
    ),
    Event(
      "8",
      "Отлично!",
      "mascot",
      "Ты перешел на второй уровень, теперь тебе всё можно в приложении и ты уже намного лучше разбираешься в инвестициях, самое время двигаться дальше и открыть брокерский счёт в Инвестициях ВТБ.",
      1,
      0,
    ),
    Event(
      "9",
      "Больше лайков",
      "https://www.film.ru/sites/default/files/images/01(229).jpg",
      "Лайкнуть комментарии в трёх различных вопросах.",
      3,
      5,
    ),
    Event(
      "10",
      "Хороший вопрос",
      "https://image.shutterstock.com/image-vector/thats-good-question-retro-speech-260nw-381206650.jpg",
      "Лайкнуть чужой вопрос, который больше всего нравится.",
      1,
      5,
    ),
    Event(
      "11",
      "Отвечают знатоки",
      "https://www.workle.ru/s3storage/commonfiles/e74f0a11-3636-4830-81d0-9c002bd79d45.jpg",
      "Ответить на чужой вопрос и получить за него лайк.",
      1,
      15,
    ),
    Event(
      "12",
      "Отвечает Друзь",
      "https://media.nakanune.ru/images/pictures/image_big_157455.jpg",
      "Ответить на чужой вопрос и получить Accepted.",
      1,
      30,
    ),
    Event(
      "14",
      "VTB",
      "https://s3-symbol-logo.tradingview.com/vtbr--600.png",
      "Задать вопрос про акции #VTBR и получить за него лайк.",
      1,
      50,
    ),
  ];

  static final levels = [
    Level(
      0,
      "Новичок",
      [],
    ),
    Level(
      1,
      "Начинающий",
      ["1", "2", "3", "4", "13", "16"],
    ),
    Level(
      2,
      "Опытный",
      ["5", "6", "7", "8", "15"],
    ),
    Level(
      3,
      "Мегасупер",
      ["9", "10", "11", "12", "14"],
    )
  ];
}
