# 🚀 DailyPulse - Next Steps Roadmap
**اگلا کیا کرنا ہے؟ صحیح ترتیب میں**

---

## 🔴 **IMMEDIATE (آج/کل) - 1-2 دن**

### **Step 1: Routes میں شامل کریں**
`main.dart` میں یہ routes add کریں:
```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/student-hub-login',
      builder: (context, state) => const StudentHubLoginScreen(),
    ),
    GoRoute(
      path: '/student-hub-signup',
      builder: (context, state) => const StudentHubSignupScreen(),
    ),
    GoRoute(
      path: '/student-hub-profile-setup',
      builder: (context, state) => const StudentHubProfileSetupScreen(),
    ),
    GoRoute(
      path: '/student-hub-groups',
      builder: (context, state) => const StudentHubGroupsScreen(),
    ),
    GoRoute(
      path: '/student-hub-group-detail/:groupId',
      builder: (context, state) {
        return StudentHubGroupDetailScreen(
          groupId: state.pathParameters['groupId']!,
        );
      },
    ),
  ],
)
```

### **Step 2: Firebase Rules Set کریں**
`Firebase Console` میں Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Students can read/write their own data
    match /students/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Groups
    match /groups/{groupId} {
      allow read: if request.auth.uid in resource.data.memberUids;
      allow create: if request.auth.token.email_verified;
      allow update, delete: if resource.data.adminUid == request.auth.uid;
      
      // Nested collections
      match /{document=**} {
        allow read: if request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.memberUids;
        allow write: if get(/databases/$(database)/documents/groups/$(groupId)).data.adminUid == request.auth.uid;
      }
    }
  }
}
```

### **Step 3: Testing کریں**
```
✅ Signup کریں - نیا اکاؤنٹ
✅ Login کریں
✅ Groups دیکھیں (خالی ہوں گے)
✅ Signup دوبارہ - دوسرے role سے
```

---

## 🟡 **SHORT TERM (اگلے 2-3 دن) - UI Screens**

### **Step 4: Assignment List Screen**
نیا screen بنائیں: `student_hub_assignment_list_screen.dart`
```dart
- تمام assignments کی list
- Due date کے ساتھ
- Status (submitted/pending/overdue)
- ایک پر click کریں تو detail دیکھیں
```

**Expected UI:**
```
📋 Assignments
├─ 📝 Physics Practice (Due: May 20)  [PENDING]
├─ 📝 Chemistry B (Due: May 18)      [OVERDUE]
└─ 📝 Biology M (Due: May 22)        [SUBMITTED]
```

### **Step 5: Assignment Detail + Submit Screen**
نیا screen: `student_hub_assignment_submit_screen.dart`
```dart
- Assignment کی تفصیطات دکھائیں
- PDF دیکھنے کا option
- File upload button
- Submit button
```

### **Step 6: Quiz List Screen**
نیا screen: `student_hub_quiz_list_screen.dart`
```dart
- تمام Quizzes
- Time limit دکھائیں
- Attempted/Not Attempted
- Click کریں تو شروع ہو
```

### **Step 7: Quiz Attempt Screen** ⭐ یہ اہم ہے!
نیا screen: `student_hub_quiz_attempt_screen.dart`
```dart
FEATURES:
✅ Countdown timer
✅ سوال ایک ایک کے بعد ایک
✅ اختیارات (A, B, C, D)
✅ اگلا/پچھلا سوال
✅ Submit button
✅ Result immediately (auto-graded)

LOGIC:
1. Quiz شروع ہو
2. Timer چلنے لگے (30 منٹ یا جو خیا ہو)
3. سوالات دیکھیں
4. اختیار منتخب کریں
5. Submit کریں
6. فوری score دیکھیں!
```

---

## 🟠 **MEDIUM TERM (3-4 دن) - Advanced Features**

### **Step 8: Teacher Dashboard Screen**
نیا screen: `student_hub_teacher_dashboard_screen.dart`
```dart
- اپنے تمام groups
- ہر group میں:
  - کتنی assignments بھیجیں
  - کتنی quizzes
  - کتنے submissions
  - اعدادوشمار
```

### **Step 9: Submissions Viewing Screen** (Teacher)
نیا screen: `student_hub_view_submissions_screen.dart`
```dart
Assignments:
- تمام students کی submissions دیکھیں
- PDF preview کریں
- Status: Pending/Late/Graded
- Grade دیں

Quizzes:
- Responses دیکھیں
- Score دیکھیں
- Comment لکھیں
```

### **Step 10: Create Assignment Screen** (Teacher)
نیا screen: `student_hub_create_assignment_screen.dart`
```dart
- Title, Description
- Due date picker
- File upload
- Save button
```

### **Step 11: Create Quiz Screen** (Teacher)
نیا screen: `student_hub_create_quiz_screen.dart`
```dart
- Quiz title
- Add questions dynamically
- ہر question میں:
  - Question text
  - 4 options (A, B, C, D)
  - Correct answer selector
- Due date
- Time limit
- Save button
```

---

## 🔵 **LONG TERM (1-2 ہفتے) - Polish + Features**

### **Step 12: FCM Notifications** 🔔
```dart
NOTIFICATIONS:
✅ Assignment created → "نیا assignment: Physics"
✅ 24 hours before due → "24 گھنٹے بچے"
✅ 1 hour before due → "1 گھنٹہ بچا! جمع کریں"
✅ Overdue → "Overdue! دیر سے جمع کریں"
✅ Quiz created → "نئی quiz: Chemistry"
✅ Submission graded → "نمبر ملے! دیکھیں"
```

### **Step 13: Analytics Dashboard**
```dart
STUDENT VIEW:
- Assignment completion %
- Quiz scores trend
- Performance graph
- Streak count

TEACHER VIEW:
- Class average
- Performance distribution
- Late submission %
- Quiz difficulty analysis
```

### **Step 14: Rich Text Editor**
```dart
Assignment descriptions میں:
- Bold, Italic, Underline
- Links
- Images
- Code blocks
```

### **Step 15: File Management**
```dart
FIREBASE STORAGE:
- Assignment PDFs
- Submission files
- Student uploaded documents
- Preview functionality
```

---

## 📊 **Priority Matrix - کون سا پہلے کریں**

```
HIGH IMPACT + EASY (پہلے یہ کریں):
✅ Routes setup
✅ Firebase Rules
✅ Testing
✅ Assignment List Screen
✅ Quiz List Screen

HIGH IMPACT + MEDIUM (پھر یہ):
✅ Quiz Attempt Screen (timer + auto-grade)
✅ Assignment Submit Screen
✅ Create Assignment/Quiz screens

MEDIUM IMPACT + EASY (بعد میں):
✅ Teacher Dashboard
✅ Submissions Viewing

NICE TO HAVE:
✅ Notifications
✅ Analytics
✅ Rich Editor
```

---

## 🎯 **Recommended Timeline**

| Phase | Time | Focus |
|-------|------|-------|
| **Phase 1** | 1 day | Routes + Rules + Testing |
| **Phase 2** | 2 days | List screens (Assignments, Quizzes) |
| **Phase 3** | 2 days | Submit screens + Quiz timer |
| **Phase 4** | 2 days | Teacher features |
| **Phase 5-6** | 3-4 days | Polish, notifications, analytics |

---

## 🚀 **Start with THIS - پہلا کام**

### **Today/Tomorrow - یہ ٹھیک کریں:**

**1. main.dart میں routes add کریں**
```dart
import 'student_hub_login_screen.dart';
import 'student_hub_signup_screen.dart';
// etc...

// GoRouter میں routes شامل کریں
```

**2. Firebase rules set کریں**
```
Firebase Console → Firestore → Rules
↓
Copy-paste the rules above
↓
Publish
```

**3. Test کریں**
```
✅ App run کریں
✅ Login route کھولیں
✅ Signup کریں ایک اکاؤنٹ
✅ Login کریں
✅ Groups screen دیکھیں
```

---

## 📋 **Next 3 Features (سب سے اہم)**

### **#1: Assignment جمع کرنا**
```dart
Why: طالب علم کا بنیادی کام ہے
Time: 1 day
Priority: 🔴 HIGHEST
```

### **#2: Quiz attempt + auto-grade**
```dart
Why: خودکار نمبر دینا best feature ہے
Time: 1.5 days
Priority: 🔴 HIGHEST
```

### **#3: Create assignment/quiz (Teacher)**
```dart
Why: استاد کام دے سکیں
Time: 1.5 days
Priority: 🔴 HIGHEST
```

---

## ✅ **Checklist - اگلے 3 دن**

- [ ] Routes setup `main.dart`
- [ ] Firebase rules deployed
- [ ] Tested: signup/login/groups
- [ ] Created: Assignment List screen
- [ ] Created: Quiz List screen
- [ ] Created: Assignment Submit screen
- [ ] Created: Quiz Attempt screen (with timer!)
- [ ] Tested: Quiz auto-grading
- [ ] Created: Create Assignment screen
- [ ] Created: Create Quiz screen

---

## 🎓 **Learn Resources (اگر ضرورت ہو)**

```
GoRouter: https://pub.dev/packages/go_router
Countdown Timer: https://pub.dev/packages/flutter_countdown_timer
File Upload: https://pub.dev/packages/file_picker
PDF Preview: https://pub.dev/packages/pdfx
```

---

## 💬 **Questions to Ask**

1. **UI Design**: موجودہ dark theme رکھوں؟
2. **Timer**: Quiz میں exact time limit چاہیے؟
3. **File Upload**: Firebase Storage استعمال کریں؟
4. **Notifications**: فوری local یا FCM?
5. **Analytics**: Student graphs ضروری ہیں؟

---

## 🎉 **Bottom Line**

**آج/کل:** Routes + Firebase + Testing (1 day)  
**2-3 دن:** Assignment/Quiz screens + Auto-grade ⭐  
**4-5 دن:** Teacher features  
**1 ہفتہ:** Polish + Notifications  

**ہماری ترجیح:**
1. ✅ Assignment submit کرنا کام کریں
2. ✅ Quiz timer + auto-grade کام کریں
3. ✅ Teacher کو create کرنے دیں
4. ✅ پھر analytics, notifications وغیرہ

---

**کون سی screen پہلے بناریں؟ بتا دے تو شروع ہو جاتے ہیں!** 🚀


