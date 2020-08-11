import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Shogi-Ban Demo Page'),
          ),
          body: Column(children: const <Widget>[
            Padding(padding: EdgeInsets.only(top: 12)),
            ShogiBan(),
          ]),
        ));
  }
}

T asIs<T>(T e) => e;

class ShogiBan extends StatefulWidget {
  const ShogiBan({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ShogiBanState();
}

class ShogiBanState extends State<ShogiBan> {
  _Board board = _Board(<_Koma>[]);
  final List<Map<_KomaId, _Koma>> history = <Map<_KomaId, _Koma>>[];
  List<void Function()> scenario = <void Function()>[];

  void pushHistory() {
    history.add(board.snapShot);
  }

  void popHistory() {
    if (history.isNotEmpty) {
      board = _Board.fromSnapShot(history.removeLast());
    }
  }

  void nextScenario() {
    if (history.length == scenario.length) {
      return;
    }
    pushHistory();
    scenario[history.length - 1]();
  }

  void init() {
    history.clear();
    board = _Board(<_Koma>[
      ...<int>[1, 2, 3, 4, 5, 6, 7, 8, 9]
          .map((int x) => <_Koma>[
                _Koma(Koma.fu, _KomaPosition(Owner.gote, _Position(x, 3))),
                _Koma(Koma.fu, _KomaPosition(Owner.sente, _Position(x, 7))),
              ])
          .expand(asIs),
      ...const <_Koma>[
        _Koma(Koma.kyoSha, _KomaPosition(Owner.gote, _Position(1, 1))),
        _Koma(Koma.kyoSha, _KomaPosition(Owner.gote, _Position(9, 1))),
        _Koma(Koma.kyoSha, _KomaPosition(Owner.sente, _Position(1, 9))),
        _Koma(Koma.kyoSha, _KomaPosition(Owner.sente, _Position(9, 9))),
      ],
      ...const <_Koma>[
        _Koma(Koma.keiMa, _KomaPosition(Owner.gote, _Position(2, 1))),
        _Koma(Koma.keiMa, _KomaPosition(Owner.gote, _Position(8, 1))),
        _Koma(Koma.keiMa, _KomaPosition(Owner.sente, _Position(2, 9))),
        _Koma(Koma.keiMa, _KomaPosition(Owner.sente, _Position(8, 9))),
      ],
      ...const <_Koma>[
        _Koma(Koma.ginSho, _KomaPosition(Owner.gote, _Position(3, 1))),
        _Koma(Koma.ginSho, _KomaPosition(Owner.gote, _Position(7, 1))),
        _Koma(Koma.ginSho, _KomaPosition(Owner.sente, _Position(3, 9))),
        _Koma(Koma.ginSho, _KomaPosition(Owner.sente, _Position(7, 9))),
      ],
      ...const <_Koma>[
        _Koma(Koma.kinSho, _KomaPosition(Owner.gote, _Position(4, 1))),
        _Koma(Koma.kinSho, _KomaPosition(Owner.gote, _Position(6, 1))),
        _Koma(Koma.kinSho, _KomaPosition(Owner.sente, _Position(4, 9))),
        _Koma(Koma.kinSho, _KomaPosition(Owner.sente, _Position(6, 9))),
      ],
      ...const <_Koma>[
        _Koma(Koma.hiSha, _KomaPosition(Owner.gote, _Position(8, 2))),
        _Koma(Koma.kaku, _KomaPosition(Owner.gote, _Position(2, 2))),
        _Koma(Koma.hiSha, _KomaPosition(Owner.sente, _Position(2, 8))),
        _Koma(Koma.kaku, _KomaPosition(Owner.sente, _Position(8, 8))),
      ],
      ...const <_Koma>[
        _Koma(Koma.ohSho, _KomaPosition(Owner.gote, _Position(5, 1))),
        _Koma(Koma.gyokuSho, _KomaPosition(Owner.sente, _Position(5, 9))),
      ],
    ]);
    // TODO: 棋譜から以下のシナリオ関数を生成する
    scenario = <void Function()>[
      () {
        // ▲6六歩
        final _KomaId id = board
            .idOfPosition(const _KomaPosition(Owner.sente, _Position(7, 7)));
        board.moveTo(id, const _KomaPosition(Owner.sente, _Position(7, 6)));
      },
      () {
        // △3四歩
        final _KomaId id = board
            .idOfPosition(const _KomaPosition(Owner.gote, _Position(3, 3)));
        board.moveTo(id, const _KomaPosition(Owner.gote, _Position(3, 4)));
      },
      () {
        // ▲2二角成
        final _KomaId id = board
            .idOfPosition(const _KomaPosition(Owner.sente, _Position(8, 8)));
        board
          ..moveTo(id, const _KomaPosition(Owner.sente, _Position(2, 2)))
          ..nari(id);
      },
      () {
        // △同銀
        final _KomaId id = board
            .idOfPosition(const _KomaPosition(Owner.gote, _Position(3, 1)));
        board.moveTo(id, const _KomaPosition(Owner.gote, _Position(2, 2)));
      },
    ];
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  List<Widget> _mochiGoma(List<_Koma> mochiGoma, double boardSize) => <Widget>[
        ...mochiGoma
            .fold(<Koma, int>{}, (Map<Koma, int> m, _Koma k) {
              if (m.containsKey(k.koma)) {
                m[k.koma]++;
              } else {
                m[k.koma] = 1;
              }
              return m;
            })
            .entries
            .map((MapEntry<Koma, int> ent) => Stack(children: <Widget>[
                  ...Iterable<Widget>.generate(
                      ent.value,
                      (int i) => Container(
                          padding: EdgeInsets.only(
                              top: (i % 7) * 8.0,
                              left: boardSize / 18 * (i / 7).floorToDouble()),
                          child: _KomaTip(ent.key, boardSize / 9))),
                ]))
      ];

  Widget _xAxis(double boardSize) => Container(
      width: boardSize,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: '9,8,7,6,5,4,3,2,1'
              .split(',')
              .map((String x) =>
                  SizedBox(width: boardSize / 9, child: Center(child: Text(x))))
              .toList()));

  Widget _yAxis(double sidePadding, double boardSize) => Container(
      width: sidePadding,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: '一,二,三,四,五,六,七,八,九'
              .split(',')
              .map((String x) => Container(
                  alignment: Alignment.center,
                  height: boardSize / 9,
                  child: Text(x)))
              .toList()));
  Widget _grid(double boardSize) => CustomPaint(
        size: Size(boardSize, boardSize),
        painter: const _GridPainter(),
      );

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final Size size = mq.size;
    final EdgeInsets pad = mq.padding;
    final double width = size.width - pad.left - pad.right;
    const double sidePadding = 32;
    final double boardSize = width - sidePadding * 2;
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: boardSize,
                alignment: Alignment.bottomRight,
                child: RotatedBox(
                    quarterTurns: 90,
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        width: boardSize,
                        height: boardSize / 4,
                        child: Wrap(
                          children: _mochiGoma(board.goteMochiGoma, boardSize),
                        )))),
            const Padding(padding: EdgeInsets.only(top: 12)),
            _xAxis(boardSize),
            Container(
                height: boardSize,
                width: width,
                padding: const EdgeInsets.only(left: sidePadding),
                child: Row(children: <Widget>[
                  Stack(children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.amber,
                          boxShadow: <BoxShadow>[
                            BoxShadow(blurRadius: 2.0),
                            BoxShadow(offset: Offset(1, 1), blurRadius: 3.0)
                          ]),
                      width: boardSize,
                      height: boardSize,
                    ),
                    _grid(boardSize),
                    SizedBox(
                        width: boardSize,
                        height: boardSize,
                        child: Stack(
                          children: <Widget>[
                            ...board.onBoard.map((_Koma e) => _PlayingKoma(
                                key: ValueKey<_KomaId>(board.idOf(e)),
                                boardSize: boardSize,
                                koma: e))
                          ],
                        )),
                  ]),
                  _yAxis(sidePadding, boardSize),
                ])),
            const Padding(padding: EdgeInsets.only(top: 12)),
            Container(
                width: boardSize,
                alignment: Alignment.bottomLeft,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  width: boardSize,
                  height: boardSize / 4,
                  child: Wrap(
                    children: _mochiGoma(board.senteMochiGoma, boardSize),
                  ),
                )),
            const Padding(padding: EdgeInsets.only(top: 12)),
            Row(
              children: <Widget>[
                RaisedButton(
                  child: const Text('init'),
                  onPressed: () {
                    setState(init);
                  },
                ),
                RaisedButton(
                  child: const Text('prev'),
                  onPressed: () {
                    setState(popHistory);
                  },
                ),
                RaisedButton(
                  child: const Text('next'),
                  onPressed: () {
                    setState(nextScenario);
                  },
                )
              ],
            )
          ]),
    );
  }
}

enum Owner {
  sente,
  gote,
  removed, // 詰将棋のときなど表記しない場合
}

enum Koma {
  fu,
  kyoSha,
  keiMa,
  ginSho,
  kinSho,
  hiSha,
  kaku,
  ohSho,
  gyokuSho,
  toKin,
  nariKyo,
  nariKei,
  nariGin,
  ryuOh,
  ryuMa,
}

extension KomaEnum on Koma {
  String get name {
    switch (this) {
      case Koma.fu:
        return '歩';
      case Koma.kyoSha:
        return '香';
      case Koma.keiMa:
        return '桂';
      case Koma.hiSha:
        return '飛';
      case Koma.kaku:
        return '角';
      case Koma.ginSho:
        return '銀';
      case Koma.kinSho:
        return '金';
      case Koma.ohSho:
        return '王';
      case Koma.gyokuSho:
        return '玉';
      case Koma.toKin:
        return 'と';
      case Koma.nariKyo:
        return '杏';
      case Koma.nariKei:
        return '圭';
      case Koma.nariGin:
        return '全';
      case Koma.ryuOh:
        return '竜';
      case Koma.ryuMa:
        return '馬';
      default:
        throw Exception('unknown koma');
    }
  }

  bool get isNari {
    switch (this) {
      case Koma.fu:
      case Koma.kyoSha:
      case Koma.keiMa:
      case Koma.hiSha:
      case Koma.kaku:
      case Koma.ginSho:
      case Koma.kinSho:
      case Koma.ohSho:
      case Koma.gyokuSho:
        return false;
      case Koma.toKin:
      case Koma.nariKyo:
      case Koma.nariKei:
      case Koma.nariGin:
      case Koma.ryuOh:
      case Koma.ryuMa:
        return true;
      default:
        throw Exception('unknown koma');
    }
  }

  Koma get toFront {
    switch (this) {
      case Koma.fu:
      case Koma.kyoSha:
      case Koma.keiMa:
      case Koma.hiSha:
      case Koma.kaku:
      case Koma.ginSho:
      case Koma.kinSho:
      case Koma.ohSho:
      case Koma.gyokuSho:
        return this;
      case Koma.toKin:
        return Koma.fu;
      case Koma.nariKyo:
        return Koma.kyoSha;
      case Koma.nariKei:
        return Koma.keiMa;
      case Koma.nariGin:
        return Koma.ginSho;
      case Koma.ryuOh:
        return Koma.hiSha;
      case Koma.ryuMa:
        return Koma.kaku;
      default:
        throw Exception('unknown koma');
    }
  }

  Koma get toNari {
    switch (this) {
      case Koma.fu:
        return Koma.toKin;
      case Koma.kyoSha:
        return Koma.nariKyo;
      case Koma.keiMa:
        return Koma.nariKei;
      case Koma.hiSha:
        return Koma.ryuOh;
      case Koma.kaku:
        return Koma.ryuMa;
      case Koma.ginSho:
        return Koma.nariGin;
      case Koma.kinSho:
      case Koma.ohSho:
      case Koma.gyokuSho:
      case Koma.toKin:
      case Koma.nariKyo:
      case Koma.nariKei:
      case Koma.nariGin:
      case Koma.ryuOh:
      case Koma.ryuMa:
        return this;
      default:
        throw Exception('unknown koma');
    }
  }
}

extension OwnerEnum on Owner {
  bool get isSente => this == Owner.sente;
  bool get isGote => this == Owner.gote;
  bool get isRemoved => this == Owner.removed;
  Owner get opposite => isRemoved ? null : (isSente ? Owner.gote : Owner.sente);
}

@immutable
class _Position {
  const _Position(this.x, this.y)
      : assert(1 <= x && x <= 9 || x == 0 && y == 0,
            'x must be 1 to 9 or use _Position.taken'),
        assert(1 <= y && y <= 9 || y == 0 && x == 0,
            'y must be 1 to 9 or use _Position.taken');
  static const _Position taken = _Position(0, 0);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is _Position && x == other.x && y == other.y;

  @override
  int get hashCode => hashList(<Object>[x, y]);
}

@immutable
class _KomaPosition {
  const _KomaPosition(this.owner, this.position);
  final Owner owner;
  final _Position position;
  _KomaPosition get taken => _KomaPosition(owner.opposite, _Position.taken);

  _KomaPosition moveTo(_Position position) => _KomaPosition(owner, position);

  @override
  bool operator ==(Object other) =>
      other is _KomaPosition &&
      owner == other.owner &&
      position == other.position;

  @override
  int get hashCode => hashList(<Object>[owner, position]);
}

@immutable
class _Koma {
  const _Koma(this.koma, this.komaPosition);
  _Koma get taken => _Koma(koma, komaPosition.taken);

  final Koma koma;
  final _KomaPosition komaPosition;
}

@immutable
class _KomaId {
  const _KomaId(this._key);
  final int _key;
  @override
  bool operator ==(Object other) => other is _KomaId && _key == other._key;

  @override
  int get hashCode => _key;
}

class _Board {
  _Board(List<_Koma> komaList)
      : _komaMap = komaList.asMap().map<_KomaId, _Koma>(
            (int key, _Koma value) =>
                MapEntry<_KomaId, _Koma>(_KomaId(key), value));

  _Board.fromSnapShot(Map<_KomaId, _Koma> snapShot)
      : _komaMap = Map<_KomaId, _Koma>.from(snapShot);

  final Map<_KomaId, _Koma> _komaMap;
  Map<_KomaId, _Koma> get snapShot =>
      Map<_KomaId, _Koma>.unmodifiable(_komaMap);

  _KomaId idOf(_Koma koma) => _komaMap.entries
      .where((MapEntry<_KomaId, _Koma> e) => e.value == koma)
      .first
      .key;

  _KomaId idOfPosition(_KomaPosition position) {
    final Iterable<MapEntry<_KomaId, _Koma>> a = _komaMap.entries.where(
        (MapEntry<_KomaId, _Koma> e) => e.value.komaPosition == position);
    if (a.isEmpty) {
      return null;
    }
    return a.first.key;
  }

  void moveTo(_KomaId id, _KomaPosition position) {
    final _KomaId taken =
        idOfPosition(_KomaPosition(position.owner.opposite, position.position));
    if (taken != null) {
      take(taken);
    }
    _komaMap[id] = _Koma(
        _komaMap[id].koma, _komaMap[id].komaPosition.moveTo(position.position));
  }

  void nari(_KomaId id) =>
      _komaMap[id] = _Koma(_komaMap[id].koma.toNari, _komaMap[id].komaPosition);

  void take(_KomaId id) => _komaMap[id] =
      _Koma(_komaMap[id].koma.toFront, _komaMap[id].komaPosition.taken);

  List<_Koma> get goteMochiGoma => _komaMap.values
      .where((_Koma e) =>
          e.komaPosition.owner.isGote &&
          e.komaPosition.position == _Position.taken)
      .toList()
        ..sort((_Koma a, _Koma b) =>
            Koma.values.indexOf(a.koma).compareTo(Koma.values.indexOf(b.koma)));
  List<_Koma> get senteMochiGoma => _komaMap.values
      .where((_Koma e) =>
          e.komaPosition.owner.isSente &&
          e.komaPosition.position == _Position.taken)
      .toList()
        ..sort((_Koma a, _Koma b) =>
            Koma.values.indexOf(a.koma).compareTo(Koma.values.indexOf(b.koma)));
  List<_Koma> get onBoard => _komaMap.values
      .where((_Koma e) =>
          !e.komaPosition.owner.isRemoved &&
          e.komaPosition.position != _Position.taken)
      .toList();
}

class _KomaTip extends StatelessWidget {
  const _KomaTip(this.koma, this.size, {Key key}) : super(key: key);

  final Koma koma;
  final double size;

  @override
  Widget build(BuildContext context) => Stack(children: <Widget>[
        SizedBox(
            width: size,
            height: size,
            child: const Center(
                child: Text(
              '☗',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.amberAccent,
                  shadows: <Shadow>[
                    Shadow(blurRadius: 3),
                    Shadow(offset: Offset(1.5, 1.5), blurRadius: 2)
                  ]),
            ))),
        Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Text(koma.name,
                style: TextStyle(
                  color: koma.isNari ? Colors.red : null,
                ))),
      ]);
}

class _PlayingKoma extends StatefulWidget {
  const _PlayingKoma({Key key, this.boardSize, this.koma}) : super(key: key);

  final double boardSize;
  final _Koma koma;

  @override
  State<StatefulWidget> createState() => _PlayingKomaState();
}

class _PlayingKomaState extends State<_PlayingKoma> {
  Koma get koma => widget.koma.koma;
  _KomaPosition get komaPosition => widget.koma.komaPosition;
  double get _size => widget.boardSize / 9;

  Widget get _komaTip => RotatedBox(
      quarterTurns: komaPosition.owner.isSente ? 0 : 90,
      child: _KomaTip(koma, _size));

  @override
  Widget build(BuildContext context) {
    return komaPosition.owner.isRemoved
        ? const SizedBox()
        : AnimatedPositioned.fromRect(
            duration: const Duration(milliseconds: 120),
            rect: Rect.fromPoints(
              Offset(
                widget.boardSize - _size * komaPosition.position.x,
                _size * (komaPosition.position.y - 1),
              ),
              Offset(
                widget.boardSize - _size * (komaPosition.position.x - 1),
                _size * komaPosition.position.y,
              ),
            ),
            child: _komaTip);
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({Listenable repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final double pitch = size.width / 9;
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final Path path = Path();

    final Paint dotsFill = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;
    final Path dots = Path();
    for (int x = 1; x < 9; x++) {
      path
        ..moveTo(pitch * x, 0)
        ..lineTo(pitch * x, size.height);
    }
    for (int y = 1; y < 9; y++) {
      path
        ..moveTo(0, pitch * y)
        ..lineTo(size.width, pitch * y);
    }
    dots
      ..addOval(Rect.fromCenter(
          center: Offset(pitch * 3, pitch * 3), width: 5, height: 5))
      ..addOval(Rect.fromCenter(
          center: Offset(pitch * 3, pitch * 6), width: 5, height: 5))
      ..addOval(Rect.fromCenter(
          center: Offset(pitch * 6, pitch * 3), width: 5, height: 5))
      ..addOval(Rect.fromCenter(
          center: Offset(pitch * 6, pitch * 6), width: 5, height: 5));
    canvas..drawPath(path, paint)..drawPath(dots, dotsFill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
