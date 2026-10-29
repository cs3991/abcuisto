# Architecture

## App structure and dependencies

- `lib/main.dart` configures the app and provides one shared `AbcuistoRepository` together with app-wide Cubits using `Provider` and `MultiBlocProvider`.
- `lib/models/` contains domain models and `AbcuistoRepository`, which owns API access, response-to-model conversion, and persisted authentication data.
- `lib/login/`, `lib/recipe/`, and other feature folders group screens and state management by feature. Keep feature-specific Cubits and their states alongside that feature.
- Widgets render state and dispatch user intents. They should not make API requests directly.

Inject the repository into Cubits through their constructors. Keep the dependency direction: widgets dispatch actions to Cubits, Cubits coordinate business logic and repository calls, and the repository handles data access.

## State management

Use `Cubit` for business logic and app or feature state wherever practical. A Cubit should own decisions and state that affect application behavior, including authentication, recipe loading and mutations, comments, and filters. Do not move such logic into a widget's `State`.

- Give each cohesive feature concern its own Cubit and immutable state, and inject required dependencies such as `AbcuistoRepository` through the Cubit's constructor.
- Expose intent-oriented methods on the Cubit (for example, `logIn`, `fetchNextPage`, or `createRecipe`). Keep widgets responsible for collecting input and dispatching those intents.
- Emit state for meaningful transitions, especially asynchronous loading, success, and failure. Represent errors in state so the UI can display or respond to them; do not silently discard failures.
- For synchronous changes to related values, keep them together in a state object and use a `copyWith`-style update so unrelated values are preserved. Use distinct state types when states are mutually exclusive, as in authentication and recipe loading.
- Keep one clear state representation per Cubit. The code uses both distinct state subclasses (`AuthenticationCubit`, `RecipeCubit`, and `AddRecipeCubit`) and state objects with status/data fields (`CommentCubit` and `FilterCubit`); choose the form that fits the concern and do not combine competing patterns within one Cubit.
- Provide Cubits at the narrowest scope that matches their lifetime. Reuse app-level instances registered in `main.dart` when the state is shared across screens.
- Prefer explicit coordination through the UI when one Cubit's change should trigger an action in another Cubit. Use `BlocListener`/`BlocConsumer` to observe the source Cubit's state and call an intent on the destination Cubit. Avoid repository `ChangeNotifier` listeners, Cubit-to-Cubit stream subscriptions, and other implicit cross-feature coupling when UI coordination is suitable.

Use `BlocBuilder` or `context.select` to render from state, and `BlocListener`/`BlocConsumer` for one-off effects such as navigation-adjacent feedback or snack bars. Do not duplicate Cubit-owned business state in widgets.

## Stateful widgets

Prefer `StatelessWidget` when a screen can render from its inputs and provided state. Use `StatefulWidget` only for simple, local UI mechanics that do not represent business or shared application state, such as owning and disposing `TextEditingController`s, a temporary animation/expansion state, or an in-progress slider drag value. If a value affects filtering, authentication, recipes, or another business decision, put it in a Cubit instead.

## How we work together

- Always write commit messages in English.
- Use only rounded icons (`Icons.*_rounded`) for new or modified UI.
- While working, record concrete inconsistencies, bugs, and improvement opportunities in the root `todo.md`. Keep this file growing without overwriting existing entries, avoid duplicates, and include enough context for another chat to act on each item. Briefly mention new findings to the user, but keep unrelated fixes outside the current task.

Keep the user involved in architectural decisions. The user wants to understand how the app is structured and retain control over changes that affect its architecture.

### Small, focused changes

For a small change contained in roughly 10–20 lines, or another clearly local fix with no architectural consequences, inspect the relevant code and implement it directly. Briefly explain what changed and why. Do not add ceremony or stop for a review before making a straightforward requested edit.

### Larger changes and architecture

When a request spans features, introduces a new architectural pattern, changes dependencies or navigation, or otherwise needs design decisions, first explain the proposed structure and the key choices in plain language. Break the work into reviewable milestones. Each milestone should have a clear behavior and limited scope.

Implement one milestone at a time, then stop and ask the user to review the concrete result before moving on. Explain the state flow and important decisions so the user can understand and steer the architecture. Incorporate feedback before continuing. Do not silently implement all milestones in one pass.

Treat commits as milestone boundaries. Commit a reviewed milestone when the user asks to commit it; do not create commits without authorization. If the user asks to commit and continue, commit the reviewed work, then proceed to the next milestone and pause for review again.

For a requested refactor, simplify the code in place when practical. Avoid introducing extra Cubits, listeners, abstractions, or state just to save a few lines. Explain any necessary async or navigation flow when it is not obvious.

## Modification and verification workflow

For requested modifications, work “blindly”: do not run the app or tests, add tests, or format files. Inspect the relevant implementation before editing and keep changes focused. The user validates behavior by running the app and reports issues. State clearly when runtime behavior was not verified. If the user explicitly asks to test or verify, follow that instruction for the requested checks.
