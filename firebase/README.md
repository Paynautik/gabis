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
command above.

A build without that file works and says so: the plugin is applied only when
the file is there, and skipped with a line in the log when it is not. Firebase
is then unavailable in that build — sign-in and sync included — which is the
right trade for a clone that only wants to run the app. gabis signs in with
email and password and uses no Google sign-in, so there are no SHA
fingerprints to register either.

`DefaultFirebaseOptions.currentPlatform` returns null on Android on purpose:
the native SDK reads `google-services.json`, and passing it the web app's
options would point the phone at the wrong app record.

## Separating the rules from trustos

Firestore rules are per **database**, not per app, so while both apps ran on
`(default)` a rules deploy from either side replaced the other's. gabis now has
a database of its own — `gabis` — with `firestore.gabis.rules`, its own indexes,
and a deploy target that cannot reach the database trustos runs on.

The code is written for it and still points at `(default)`, because creating
the second database needs the project on Blaze and a build aimed at a database
nobody had created yet would quietly stop syncing for everyone already signed
in. Three steps, in this order:

```bash
# 1. Make the database (needs Blaze)
firebase firestore:databases:create gabis --location nam5 --project paynautic

# 2. Copy what gabis already wrote. Reports first; --commit does it.
GOOGLE_APPLICATION_CREDENTIALS=<service-account.json> \
  npm --prefix firebase/functions run migrate
GOOGLE_APPLICATION_CREDENTIALS=<service-account.json> \
  npm --prefix firebase/functions run migrate -- --commit

# 3. Point both halves at it, together
flutter build web --release --dart-define=FIRESTORE_DB=gabis
firebase functions:config:set  # or set FIRESTORE_DB=gabis on the function
firebase deploy --only functions,firestore --project paynautic
```

The migration copies rather than moves: nothing is deleted from `(default)`, so
if the new database turns out wrong the old copy is still there. Clearing it out
afterwards is a console operation, once you are satisfied.

`firestore.rules` is still in this repository and describes gabis alone on
`(default)`. It is not referenced by `firebase.json` any more, and it must not
be deployed: doing so would replace the rules trustos runs on.

## Indexes

`firestore.indexes.json` carries two the chaser cannot run without:

- a **collection-group** index on `gabis.autonomous`, because collection-group
  queries are not served by Firestore's automatic single-field indexes, and the
  scheduled pass finds the businesses that opted in with exactly that query;
- a composite on `attempts (debtor_name, placed_at)`, because an equality on
  one field ordered by another needs one — and that query is what the
  escalation counts.

Both deploy with `firebase deploy --only firestore`.
