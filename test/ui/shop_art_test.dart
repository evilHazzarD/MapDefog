import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/domain/quests.dart';
import 'package:mapdefog/ui/treasury/shop_art.dart';

void main() {
  testWidgets('every fog style and boost has art that paints', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            for (final st in Shop.styles) SizedBox(width: 150, child: FogSwatch(st.id)),
            Row(children: [for (final a in BoostArt.values) BoostIcon(a, color: Colors.brown)]),
          ],
        ),
      ),
    );

    expect(find.byType(FogSwatch), findsNWidgets(Shop.styles.length));
    expect(find.byType(BoostIcon), findsNWidgets(BoostArt.values.length));
    expect(tester.takeException(), isNull);
  });
}
