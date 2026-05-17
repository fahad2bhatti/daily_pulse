# 📚 Student Hub - Quick Reference Guide

## 🔐 Authentication Flow

### 1. Signup
```dart
// Signup Screen se call karte ho
await ref.read(signupProvider(
  SignupParams(
    email: 'student@example.com',
    password: 'password123',
    name: 'Ahmed Ali',
    role: UserRole.student,
  ),
).future);
```

### 2. Login
```dart
// Login Screen se
final user = await ref.read(loginProvider(
  LoginParams(
    email: 'student@example.com',
    password: 'password123',
  ),
).future);
```

### 3. Get Current User
```dart
// Any screen mein
final currentUser = ref.watch(currentSHUserNotifierProvider);
// currentUser.isStudent, currentUser.isTeacher, etc.
```

---

## 👥 Group Management

### Student: Join Group
```dart
final groupService = ref.read(studentHubGroupServiceProvider);
final group = await groupService.joinGroupWithCode(
  inviteCode: 'ABC123',
  userUid: currentUser.uid,
);
```

### Teacher: Create Group
```dart
final groupNotifier = ref.read(groupNotifierProvider.notifier);
final group = await groupNotifier.createGroup(
  name: 'Physics 101',
  subject: 'Physics',
  adminUid: currentUser.uid,
);
// Invite code automatically generated! 🎉
```

### Get All User Groups
```dart
final groups = await ref.watch(
  userGroupsProvider(currentUser.uid)
).when(
  data: (groups) => groups,
  loading: () => [],
  error: (_, __) => [],
);
```

---

## 📝 Assignments

### Teacher: Create Assignment
```dart
final assignmentNotifier = ref.read(assignmentNotifierProvider.notifier);

await assignmentNotifier.createAssignment(
  groupId: 'group123',
  title: 'Physics Problem Set',
  description: 'Solve 10 MCQ questions',
  dueDate: DateTime.now().add(Duration(days: 3)),
  fileUrl: 'https://firebase-storage-link...',
);
```

### Student: Submit Assignment
```dart
await assignmentNotifier.submitAssignment(
  groupId: 'group123',
  assignmentId: 'assign123',
  userId: currentUser.uid,
  fileUrl: 'https://firebase-storage-upload-link...',
);
```

### Get Group Assignments
```dart
final assignments = await ref.watch(
  groupAssignmentsProvider('group123')
).when(
  data: (assignments) => assignments,
  loading: () => [],
  error: (_, __) => [],
);

// Check if completed
final submission = await ref.watch(
  assignmentSubmissionProvider(('group123', 'assign123', currentUser.uid))
);
```

### Teacher: Grade Submission
```dart
await assignmentNotifier.gradeSubmission(
  groupId: 'group123',
  submissionId: 'sub123',
  score: 8, // out of 10
);
```

---

## 🎯 Quizzes

### Teacher: Create Quiz
```dart
final quizNotifier = ref.read(quizNotifierProvider.notifier);

final questions = [
  QuizQuestion(
    question: 'What is 2+2?',
    options: ['3', '4', '5', '6'],
    correctIndex: 1, // Option B (index 1)
  ),
  QuizQuestion(
    question: 'What is 5*5?',
    options: ['20', '25', '30', '35'],
    correctIndex: 1, // Option B
  ),
];

await quizNotifier.createQuiz(
  groupId: 'group123',
  title: 'Math Quiz',
  questions: questions,
  timeLimitMin: 30, // 30 minutes
  dueDate: DateTime.now().add(Duration(days: 2)),
);
```

### Student: Attempt Quiz (Auto-Graded!)
```dart
// Check if can attempt
final canAttempt = await ref.watch(
  canAttemptQuizProvider(('group123', 'quiz123', currentUser.uid))
).when(
  data: (can) => can,
  loading: () => false,
  error: (_, __) => false,
);

if (canAttempt) {
  // User selects answers [1, 1] means option B for Q1, option B for Q2
  final submission = await quizNotifier.submitQuiz(
    groupId: 'group123',
    quizId: 'quiz123',
    userId: currentUser.uid,
    answers: [1, 1], // Selected option indexes
  );
  
  // Auto-graded! Score already calculated ✨
  print('Score: ${submission.score}'); // 2/2 if correct
}
```

### Get Quiz Submissions
```dart
final submission = await ref.watch(
  quizSubmissionProvider(('group123', 'quiz123', currentUser.uid))
).when(
  data: (sub) => sub,
  loading: () => null,
  error: (_, __) => null,
);

if (submission?.isGraded ?? false) {
  print('Your Score: ${submission.score}/2');
}
```

### Get Quiz Statistics (For Teachers)
```dart
final stats = await ref.watch(
  quizStatsProvider(('group123', 'quiz123'))
).when(
  data: (stats) => stats,
  loading: () => {},
  error: (_, __) => {},
);

print('Average Score: ${stats['averageScore']}%');
print('Highest Score: ${stats['highestScore']}');
print('Total Attempts: ${stats['totalAttempts']}');
```

---

## 🕒 Quiz Timer (for UI)

```dart
final quizService = ref.read(studentHubQuizServiceProvider);
final quiz = ...;

Duration timeRemaining = quizService.getTimeRemaining(quiz);
// Use this in a countdown timer widget
```

---

## 👥 User Roles & Permissions

```dart
if (currentUser.isStudent) {
  // Show: Join group, Submit assignments, Attempt quizzes
}

if (currentUser.isTeacher) {
  // Show: Create group, Create assignments, View submissions, Grade
}

if (currentUser.isAdmin) {
  // Full access
}
```

---

## 📊 Key Models

### Submission Status
```dart
enum SubmissionStatus { 
  pending,      // Not submitted
  submitted,    // Submitted but not graded
  graded,       // Graded (only for quizzes)
  late          // Submitted after due date
}
```

### Submission Type
```dart
enum SubmissionType { 
  assignment,   // Assignment submission
  quiz          // Quiz submission (auto-graded)
}
```

---

## 🔥 Firebase Firestore Schema

```
users/
├── {uid}/
│   ├── name, email, role, createdAt, enrolledGroups[]
│
groups/
├── {groupId}/
│   ├── name, subject, adminUid, inviteCode, memberUids[], createdAt
│   ├── assignments/
│   │   └── {assignmentId}/
│   │       ├── title, description, dueDate, fileUrl, createdAt
│   └── quizzes/
│       └── {quizId}/
│           ├── title, questions[], timeLimitMin, dueDate, createdAt
│   └── submissions/
│       └── {submissionId}/
│           ├── refId, type, userId, status, score, answers[], submittedAt
```

---

## 🚨 Error Handling

```dart
try {
  await groupNotifier.joinGroup(
    inviteCode: 'ABC123',
    userUid: currentUser.uid,
  );
} on FirebaseAuthException catch (e) {
  print('Auth Error: ${e.message}');
} on FirebaseException catch (e) {
  print('Database Error: ${e.message}');
} catch (e) {
  print('Unknown Error: $e');
}
```

---

## 💡 Tips & Best Practices

1. **Always check if user exists** before making Firestore calls
2. **Use FutureProvider** for one-time fetches
3. **Use StateNotifier** for real-time updates
4. **Quiz answers** are stored as List<int> with selected option indexes
5. **Auto-grading** happens instantly on quiz submission
6. **Invite codes** are 6 characters, auto-generated, unique per group
7. **Timestamps** use Firestore Timestamp for consistency

---

## 🎯 TODO UI Implementation

- [ ] Assignment submission screen with file upload
- [ ] Quiz attempt screen with timer countdown
- [ ] Teacher dashboard with all submissions
- [ ] Grade assignment submission screen
- [ ] Quiz results/analytics dashboard
- [ ] Member management UI
- [ ] Group invite code display/share

