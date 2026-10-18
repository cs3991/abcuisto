# Architecture

## App structure and dependencies

- `lib/main.dart` configures the app and provides one shared `AbcuistoRepository` together with the app-wide Cubits using `Provider` and `MultiBlocProvider`.
- `lib/models/` contains domain models and `AbcuistoRepository`, which owns API access, response-to-model conversion, and persisted authentication data.
- `lib/login/` and `lib/recipe/` group screens and state management by feature. Keep new feature-specific Cubits and their states alongside that feature.
- The UI is composed from Flutter widgets. Screens observe Cubit state and dispatch user intents; they should not make API requests directly.

The repository is injected into Cubits through their constructors. Keep this dependency direction: widgets dispatch actions to Cubits, Cubits coordinate business logic and repository calls, and the repository handles data access.

## State management

Use `Cubit` for business logic and app or feature state wherever practical. A Cubit should own decisions and state that affect application behavior, including authentication, recipe loading and mutations, comments, and filters. Do not move such logic into a widget's `State`.

Follow these conventions when adding or changing a Cubit:

- Give each cohesive feature concern its own Cubit and immutable state, and inject required dependencies such as `AbcuistoRepository` through the Cubit's constructor.
- Expose intent-oriented methods on the Cubit (for example, `logIn`, `fetchNextPage`, or `createRecipe`). Keep widgets responsible for collecting input and dispatching those intents.
- Emit state for meaningful transitions, especially asynchronous loading, success, and failure. Represent errors in state so the UI can display or respond to them; do not silently discard failures.
- For synchronous changes to related values, keep them together in a state object and use a `copyWith`-style update so unrelated values are preserved. Use distinct state types when states are mutually exclusive, as in authentication and recipe loading.
- Keep one clear state representation per Cubit. The existing code includes both distinct state subclasses (`AuthenticationCubit`, `RecipeCubit`, and `AddRecipeCubit`) and state objects with status/data fields (`CommentCubit` and `FilterCubit`); choose the form that fits the concern and do not combine competing patterns within one Cubit.
- Provide Cubit instances at the narrowest scope that matches their lifetime. Reuse the app-level instances already registered in `main.dart` when the state is shared across screens.

Use `BlocBuilder` or `context.select` to render from state, and `BlocListener`/`BlocConsumer` for one-off effects such as navigation-adjacent feedback or snack bars. Do not duplicate Cubit-owned business state in widgets.

## Stateful widgets

Prefer `StatelessWidget` when a screen can render from its inputs and provided state. Use `StatefulWidget` only for simple, local UI mechanics that do not represent business or shared application state, such as owning and disposing `TextEditingController`s, a temporary animation/expansion state, or an in-progress slider drag value. If a value affects filtering, authentication, recipes, or another business decision, put it in a Cubit instead.

## Modification and verification workflow

For requested modifications, work “blindly” in the sense that you do not run the app or tests, add tests, or format files. The user will validate behavior by running the app and report any issues. Still inspect the relevant implementation before editing, keep changes focused, and report that runtime behavior was not verified.
