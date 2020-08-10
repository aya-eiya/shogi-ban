import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
            title: Text('Shogi-Ban Demo Page'),
          ),
          body: Column(children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 12)),
            ShogiBan(),
          ]),
        ));
  }
}

T asIs<T>(T e) => e;

class ShogiBan extends StatefulWidget {
  _Board board = _Board([]);
  List<Map<_KomaId, _Koma>> history = [];
  List<void Function()> scenario = [];

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
      ...[1, 2, 3, 4, 5, 6, 7, 8, 9]
          .map((int x) => [
                _Koma(Koma.fu, _KomaPosition(Owner.gote, _Position(x, 3))),
                _Koma(Koma.fu, _KomaPosition(Owner.sente, _Position(x, 7))),
              ])
          .expand(asIs),
      ...[
        _Koma(Koma.kyoSha, _KomaPosition(Owner.gote, _Position(1, 1))),
        _Koma(Koma.kyoSha, _KomaPosition(Owner.gote, _Position(9, 1))),
        _Koma(Koma.kyoSha, _KomaPosition(Owner.sente, _Position(1, 9))),
        _Koma(Koma.kyoSha, _KomaPosition(Owner.sente, _Position(9, 9))),
      ],
      ...[
        _Koma(Koma.keiMa, _KomaPosition(Owner.gote, _Position(2, 1))),
        _Koma(Koma.keiMa, _KomaPosition(Owner.gote, _Position(8, 1))),
        _Koma(Koma.keiMa, _KomaPosition(Owner.sente, _Position(2, 9))),
        _Koma(Koma.keiMa, _KomaPosition(Owner.sente, _Position(8, 9))),
      ],
      ...[
        _Koma(Koma.ginSho, _KomaPosition(Owner.gote, _Position(3, 1))),
        _Koma(Koma.ginSho, _KomaPosition(Owner.gote, _Position(7, 1))),
        _Koma(Koma.ginSho, _KomaPosition(Owner.sente, _Position(3, 9))),
        _Koma(Koma.ginSho, _KomaPosition(Owner.sente, _Position(7, 9))),
      ],
      ...[
        _Koma(Koma.kinSho, _KomaPosition(Owner.gote, _Position(4, 1))),
        _Koma(Koma.kinSho, _KomaPosition(Owner.gote, _Position(6, 1))),
        _Koma(Koma.kinSho, _KomaPosition(Owner.sente, _Position(4, 9))),
        _Koma(Koma.kinSho, _KomaPosition(Owner.sente, _Position(6, 9))),
      ],
      ...[
        _Koma(Koma.hiSha, _KomaPosition(Owner.gote, _Position(8, 2))),
        _Koma(Koma.kaku, _KomaPosition(Owner.gote, _Position(2, 2))),
        _Koma(Koma.hiSha, _KomaPosition(Owner.sente, _Position(2, 8))),
        _Koma(Koma.kaku, _KomaPosition(Owner.sente, _Position(8, 8))),
      ],
      ...[
        _Koma(Koma.ohSho, _KomaPosition(Owner.gote, _Position(5, 1))),
        _Koma(Koma.gyokuSho, _KomaPosition(Owner.sente, _Position(5, 9))),
      ],
    ]);
    // TODO: 棋譜から以下のシナリオ関数を生成する
    scenario = [
      () {
        // ▲6六歩
        final _KomaId id =
            board.idOfPosition(_KomaPosition(Owner.sente, _Position(7, 7)));
        board.moveTo(id, _KomaPosition(Owner.sente, _Position(7, 6)));
      },
      () {
        // △3四歩
        final _KomaId id =
            board.idOfPosition(_KomaPosition(Owner.gote, _Position(3, 3)));
        board.moveTo(id, _KomaPosition(Owner.gote, _Position(3, 4)));
      },
      () {
        // ▲2二角成
        final _KomaId id =
            board.idOfPosition(_KomaPosition(Owner.sente, _Position(8, 8)));
        board.moveTo(id, _KomaPosition(Owner.sente, _Position(2, 2)));
        board.nari(id);
      },
      () {
        // △同銀
        final _KomaId id =
            board.idOfPosition(_KomaPosition(Owner.gote, _Position(3, 1)));
        board.moveTo(id, _KomaPosition(Owner.gote, _Position(2, 2)));
      },
    ];
  }

  @override
  State<StatefulWidget> createState() => ShogiBanState();
}

class ShogiBanState extends State<ShogiBan> {
  _Board get board => widget.board;

  @override
  void initState() {
    widget.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final Size size = mq.size;
    final EdgeInsets pad = mq.padding;
    final double boardSize = size.width - pad.left - pad.right - 128;
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
                        width: boardSize / 2,
                        height: boardSize / 4,
                        child: Wrap(
                          children: <Widget>[
                            ...board.goteMochiGoma.map((e) => _KomaTip(
                                e.koma, boardSize / 9,
                                key: ValueKey<_KomaId>(board.idOf(e))))
                          ],
                        )))),
            Padding(padding: EdgeInsets.only(top: 12)),
            Container(
                width: boardSize,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    textDirection: TextDirection.rtl,
                    children: '1,2,3,4,5,6,7,8,9'
                        .split(',')
                        .map((x) => Text(x))
                        .toList())),
            Container(
                height: boardSize,
                width: boardSize + 48,
                padding: EdgeInsets.only(left: 24),
                child: Row(children: [
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      width: boardSize,
                      height: boardSize,
                      child: Stack(
                        children: <Widget>[
                          ...board.onBoard.map((e) => _PlayingKoma(
                              key: ValueKey<_KomaId>(board.idOf(e)),
                              boardSize: boardSize,
                              koma: e))
                        ],
                      )),
                  Container(
                      width: 24,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: '一,二,三,四,五,六,七,八,九'
                              .split(',')
                              .map((x) => Text(x))
                              .toList()))
                ])),
            Padding(padding: EdgeInsets.only(top: 12)),
            Container(
                width: boardSize,
                alignment: Alignment.bottomLeft,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  width: boardSize / 2,
                  height: boardSize / 4,
                  child: Wrap(
                    children: <Widget>[
                      ...board.senteMochiGoma.map((e) => _KomaTip(
                          e.koma, boardSize / 9,
                          key: ValueKey<_KomaId>(board.idOf(e))))
                    ],
                  ),
                )),
            Padding(padding: EdgeInsets.only(top: 12)),
            Row(
              children: [
                RaisedButton(
                  child: Text('init'),
                  onPressed: () {
                    setState(() {
                      widget.init();
                    });
                  },
                ),
                RaisedButton(
                  child: Text('prev'),
                  onPressed: () {
                    setState(widget.popHistory);
                  },
                ),
                RaisedButton(
                  child: Text('next'),
                  onPressed: () {
                    setState(widget.nextScenario);
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
  hiSha,
  kaku,
  ginSho,
  kinSho,
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

class _Position {
  _Position(this.x, this.y)
      : assert(1 <= x && x <= 9 || x == 0 && y == 0),
        assert(1 <= y && y <= 9 || y == 0 && x == 0);
  static _Position get taken => _Position(0, 0);

  final int x;
  final int y;

  @override
  operator ==(Object other) =>
      other is _Position && x == other.x && y == other.y;

  @override
  int get hashCode => hashList(<Object>[x, y]);
}

class _KomaPosition {
  const _KomaPosition(this.owner, this.position);
  final Owner owner;
  final _Position position;
  _KomaPosition get taken => _KomaPosition(owner.opposite, _Position.taken);

  _KomaPosition moveTo(_Position position) => _KomaPosition(owner, position);

  @override
  operator ==(Object other) =>
      other is _KomaPosition &&
      owner == other.owner &&
      position == other.position;

  @override
  int get hashCode => hashList(<Object>[owner, position]);
}

class _Koma {
  const _Koma(this.koma, this.komaPosition);
  _Koma get taken => _Koma(this.koma, this.komaPosition.taken);

  final Koma koma;
  final _KomaPosition komaPosition;
}

class _KomaId {
  const _KomaId(this._key);
  final int _key;
  @override
  operator ==(Object other) => other is _KomaId && _key == other._key;

  @override
  int get hashCode => _key;
}

class _Board {
  _Board(List<_Koma> komaList)
      : _komaMap = komaList
            .asMap()
            .map<_KomaId, _Koma>((key, value) => MapEntry(_KomaId(key), value));

  _Board.fromSnapShot(Map<_KomaId, _Koma> snapShot)
      : _komaMap = Map.from(snapShot);

  final Map<_KomaId, _Koma> _komaMap;
  Map<_KomaId, _Koma> get snapShot => Map.unmodifiable(_komaMap);

  _KomaId idOf(_Koma koma) =>
      _komaMap.entries.where((e) => e.value == koma).first.key;

  _KomaId idOfPosition(_KomaPosition position) {
    final a = _komaMap.entries.where((e) => e.value.komaPosition == position);
    if (a.isEmpty) {
      return null;
    }
    return a.first.key;
  }

  void moveTo(_KomaId id, _KomaPosition position) {
    final taken =
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
      .where((e) =>
          e.komaPosition.owner.isGote &&
          e.komaPosition.position == _Position.taken)
      .toList()
        ..sort((a, b) =>
            Koma.values.indexOf(a.koma).compareTo(Koma.values.indexOf(b.koma)));
  List<_Koma> get senteMochiGoma => _komaMap.values
      .where((e) =>
          e.komaPosition.owner.isSente &&
          e.komaPosition.position == _Position.taken)
      .toList()
        ..sort((a, b) =>
            Koma.values.indexOf(a.koma).compareTo(Koma.values.indexOf(b.koma)));
  List<_Koma> get onBoard => _komaMap.values
      .where((e) =>
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
            child: Center(
                child: Text(
              '☖',
              style: TextStyle(fontSize: 24),
            ))),
        Container(
            width: size,
            height: size,
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 2),
            child: Text(koma.name,
                style: TextStyle(
                  color: koma.isNari ? Colors.red : null,
                ))),
      ]);
}

class _PlayingKoma extends StatefulWidget {
  _PlayingKoma({Key key, this.boardSize, this.koma}) : super(key: key);

  final double boardSize;
  _Koma koma;

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
    return AnimatedPositioned.fromRect(
        duration: Duration(milliseconds: 120),
        rect: komaPosition.owner.isRemoved
            ? const SizedBox()
            : Rect.fromPoints(
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
