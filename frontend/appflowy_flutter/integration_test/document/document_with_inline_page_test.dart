import 'package:appflowy/plugins/document/presentation/editor_plugins/mention/mention_page_block.dart';
import 'package:appflowy_backend/protobuf/flowy-folder2/protobuf.dart';
import 'package:flowy_infra/uuid.dart';
import 'package:flowy_infra_ui/widget/error_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../util/util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('inline page view in document', () {
    const location = 'inline_page';

    setUp(() async {
      await TestFolder.cleanTestLocation(location);
      await TestFolder.setTestLocation(location);
    });

    tearDown(() async {
      await TestFolder.cleanTestLocation(null);
    });

    testWidgets('insert a inline page - grid', (tester) async {
      await tester.initializeAppFlowy();
      await tester.tapGoButton();

      await insertingInlinePage(tester, ViewLayoutPB.Grid);

      final mentionBlock = find.byType(MentionPageBlock);
      expect(mentionBlock, findsOneWidget);
      await tester.tapButton(mentionBlock);
    });

    testWidgets('insert a inline page - board', (tester) async {
      await tester.initializeAppFlowy();
      await tester.tapGoButton();

      await insertingInlinePage(tester, ViewLayoutPB.Board);

      final mentionBlock = find.byType(MentionPageBlock);
      expect(mentionBlock, findsOneWidget);
      await tester.tapButton(mentionBlock);
    });

    testWidgets('insert a inline page - calendar', (tester) async {
      await tester.initializeAppFlowy();
      await tester.tapGoButton();

      await insertingInlinePage(tester, ViewLayoutPB.Calendar);

      final mentionBlock = find.byType(MentionPageBlock);
      expect(mentionBlock, findsOneWidget);
      await tester.tapButton(mentionBlock);
    });

    testWidgets('insert a inline page - document', (tester) async {
      await tester.initializeAppFlowy();
      await tester.tapGoButton();

      await insertingInlinePage(tester, ViewLayoutPB.Document);

      final mentionBlock = find.byType(MentionPageBlock);
      expect(mentionBlock, findsOneWidget);
      await tester.tapButton(mentionBlock);
    });

    testWidgets('insert a inline page and rename it', (tester) async {
      await tester.initializeAppFlowy();
      await tester.tapGoButton();

      final pageName = await insertingInlinePage(tester, ViewLayoutPB.Document);

      // rename
      await tester.hoverOnPageName(pageName);
      const newName = 'RenameToNewPageName';
      await tester.renamePage(newName);
      final finder = find.descendant(
        of: find.byType(MentionPageBlock),
        matching: find.findTextInFlowyText(newName),
      );
      expect(finder, findsOneWidget);
    });

    testWidgets('insert a inline page and delete it', (tester) async {
      await tester.initializeAppFlowy();
      await tester.tapGoButton();

      final pageName = await insertingInlinePage(tester, ViewLayoutPB.Grid);

      // rename
      await tester.hoverOnPageName(pageName);
      await tester.tapDeletePageButton();
      final finder = find.descendant(
        of: find.byType(MentionPageBlock),
        matching: find.findTextInFlowyText(pageName),
      );
      expect(finder, findsOneWidget);
      await tester.tapButton(finder);
      expect(find.byType(FlowyErrorPage), findsOneWidget);
    });
  });
}

/// Insert a referenced database of [layout] into the document
Future<String> insertingInlinePage(
  WidgetTester tester,
  ViewLayoutPB layout,
) async {
  // create a new grid
  final id = uuid();
  final name = '${layout.name}_$id';
  await tester.createNewPageWithName(
    layout,
    name,
  );
  // create a new document
  await tester.createNewPageWithName(
    ViewLayoutPB.Document,
    'insert_a_inline_page_${layout.name}',
  );
  // tap the first line of the document
  await tester.editor.tapLineOfEditorAt(0);
  // insert a inline page
  await tester.editor.showAtMenu();
  await tester.editor.tapAtMenuItemWithName(name);
  return name;
}
