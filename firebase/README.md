# Firebase in gabis

The app lives in the **paynautic** project, shared with **trustos**. That is a
constraint, not a choice: the account is at its Google Cloud project quota, so
gabis cannot have a project of its own. Everything gabis writes is under
`users/{uid}/gabis/`, which is what keeps the two apps out of each other's data.

Apps registered in the project:

| App               | Platform | Whose        |
|-------------------|----------|--------------|
| `trustos (android)` | Android | the other app |
| `trustos (web)`     | Web     | the other app |
| `gabis web`         | Web     | gabis         |

## Android

There is no `gabis android` app record yet, which is why the phone has nothing
to read. Create it and fetch the config:

```bash
firebase apps:create android "gabis android" \
  --package-name com.nautik.nautik_money --project paynautic

firebase apps:sdkconfig ANDROID <the app id it prints> \
  --project paynautic -o android/app/google-services.json
```

The Gradle plugin is already wired (`android/settings.gradle.kts` and
`android/app/build.gradle.kts`), and `google-services.json` is gitignored, so
every machine that builds the Android app fetches its own copy with the second
command above. **An Android build fails until that file exists** — that is the
plugin telling the truth rather than building an app whose Firebase calls would
all fail at runtime.

`DefaultFirebaseOptions.currentPlatform` returns null on Android on purpose:
the native SDK reads `google-services.json`, and passing it the web app's
options would point the phone at the wrong app record.

## Separating the rules from trustos

Firestore rules are per **database**, not per app, and the project has one
database (`(default)`) today. So `firebase deploy --only firestore:rules`
replaces the rules both apps run on, which is why gabis does not deploy them.

Two ways out, in order of preference:

### A second database, named `gabis`

Firestore allows more than one database per project, each with its own rules
file and its own deploy target. gabis would deploy `firestore.gabis.rules` to
the `gabis` database and could not touch trustos if it tried.

```bash
firebase firestore:databases:create gabis --location nam5 --project paynautic
```

Then in `firebase.json`:

```json
"firestore": [
  { "database": "gabis", "rules": "firestore.gabis.rules" }
]
```

and in the app, `FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'gabis')`
inside `UserSync`, plus `getFirestore(getApp(), 'gabis')` in the chaser.

The cost is a migration: whatever gabis has already written under
`users/{uid}/gabis/` in the default database stays there. Worth checking how
much that is before moving — on a project this young it may be nothing.

### One file that holds both apps' rules

Keep the single database and make `firestore.rules` the truth for both apps —
gabis's `users/{uid}/**` block plus whatever trustos needs. This works, but
every deploy from either side overwrites the other's, and the file has to be
kept in step across two repositories by hand. Only take this route if the
second database is not worth the migration.

Either way, do not run `firebase deploy --only firestore:rules` from this
repository while `firestore.rules` describes gabis alone.
