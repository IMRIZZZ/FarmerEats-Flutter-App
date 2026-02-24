import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

// Brand Colors
const Color primaryColor = Color(0xFFD5715B);
const Color activeYellow = Color(0xFFF3C052);
const Color greenColor = Color(0xFF5EA25F);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FarmerEatsApp());
}

class FarmerEatsApp extends StatelessWidget {
  const FarmerEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, fontFamily: 'Roboto'),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 1. SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  Future<void> _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (hasSeenOnboarding) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: primaryColor,
      body: Center(
          child: Text("FarmerEats",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))),
    );
  }
}

// ==========================================
// 2. ONBOARDING SCREEN
// ==========================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  DateTime? _lastPressedAt;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "color": greenColor,
      "title": "Quality",
      "text":
          "Sell your farm fresh products directly to\nconsumers, cutting out the middleman and\nreducing emissions of the global supply chain.",
      "icon": Icons.agriculture
    },
    {
      "color": primaryColor,
      "title": "Convenient",
      "text":
          "Our team of delivery drivers will make sure\nyour orders are picked up on time and\npromptly delivered to your customers.",
      "icon": Icons.home_work_outlined
    },
    {
      "color": activeYellow,
      "title": "Local",
      "text":
          "We love the earth and know you do too! Join us\nin reducing our local carbon footprint one order\nat a time.",
      "icon": Icons.park_outlined
    },
  ];

  Future<void> _completeOnboarding(Widget nextScreen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted)
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => nextScreen));
  }

  // DOUBLE TAP TO EXIT LOGIC
  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      _showSnack(context, "Press back again to exit", isError: false);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: (value) => setState(() => _currentPage = value),
          itemCount: onboardingData.length,
          itemBuilder: (context, index) {
            return Container(
              color: onboardingData[index]["color"],
              child: Column(
                children: [
                  Expanded(
                      flex: 12,
                      child: Center(
                          child: Icon(onboardingData[index]["icon"],
                              size: 150,
                              color: Colors.black.withOpacity(0.3)))),
                  Expanded(
                    flex: 11,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(45))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 35),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(onboardingData[index]["title"],
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 25),
                                Text(onboardingData[index]["text"],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14, height: 1.5)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  3,
                                  (dotIndex) => AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        width:
                                            _currentPage == dotIndex ? 22 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      )),
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width: 260,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: onboardingData[index]
                                            ["color"],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        elevation: 0),
                                    onPressed: () =>
                                        _completeOnboarding(const SignupFlow()),
                                    child: const Text("Join the movement!",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                GestureDetector(
                                  onTap: () =>
                                      _completeOnboarding(const LoginScreen()),
                                  child: const Text("Login",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// 3. LOGIN & PASSWORD RECOVERY
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  DateTime? _lastPressedAt;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      _showSnack(context, "Press back again to exit", isError: false);
      return false;
    }
    return true;
  }

  void _loginAPI() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showSnack(context, "Please enter Email and Password");
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://sowlab.com/assignment/user/login'),
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "role": "farmer",
          "device_token": "dummy_token",
          "type": "email",
          "social_id": "dummy_id"
        }),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));

      if (mounted)
        _showSnack(context, "API Response: ${response.statusCode}",
            isError: response.statusCode != 200);
    } catch (e) {
      _showSnack(
          context, "Network Error. Please check your internet connection.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("FarmerEats", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 80),
                const Text("Welcome back!",
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("New here? ",
                        style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupFlow())),
                      child: const Text("Create account",
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                ),
                const SizedBox(height: 40),
                _buildField("Email Address", Icons.alternate_email,
                    controller: emailController, isEmail: true),
                const SizedBox(height: 15),
                _buildField("Password", Icons.lock_outline,
                    obscure: true,
                    showForgot: true,
                    context: context,
                    controller: passwordController),
                const SizedBox(height: 30),
                _buildPrimaryBtn("Login", _isLoading ? null : _loginAPI,
                    isLoading: _isLoading),
                const SizedBox(height: 30),
                const Center(
                    child: Text("or login with",
                        style: TextStyle(color: Colors.grey, fontSize: 12))),
                const SizedBox(height: 20),
                _buildSocialBtns(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final phoneCtrl = TextEditingController();

  void _sendCode() {
    if (phoneCtrl.text.length != 10) {
      _showSnack(context, "Phone number must be exactly 10 digits");
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const VerifyOTPScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("FarmerEats", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 80),
              const Text("Forgot Password?",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Remember your password? ",
                      style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text("Login",
                          style: TextStyle(color: primaryColor)))
                ],
              ),
              const SizedBox(height: 40),
              _buildField("Phone Number", Icons.phone_outlined,
                  isPhone: true, maxLength: 10, controller: phoneCtrl),
              const SizedBox(height: 30),
              _buildPrimaryBtn("Send Code", _sendCode),
            ],
          ),
        ),
      ),
    );
  }
}

class VerifyOTPScreen extends StatefulWidget {
  const VerifyOTPScreen({super.key});
  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(5, (index) => TextEditingController());

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _submitOTP() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 5) {
      _showSnack(context, "Please enter all 5 digits");
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("FarmerEats", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 80),
              const Text("Verify OTP",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Remember your password? ",
                      style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (r) => false),
                      child: const Text("Login",
                          style: TextStyle(color: primaryColor))),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                    5,
                    (index) => Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1)
                            ],
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 4) {
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[index + 1]);
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[index - 1]);
                              }
                            },
                          ),
                        )),
              ),
              const SizedBox(height: 30),
              _buildPrimaryBtn("Submit", _submitOTP),
              const SizedBox(height: 20),
              const Center(
                  child: Text("Resend Code",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPassCtrl = TextEditingController();
  final confPassCtrl = TextEditingController();

  void _submit() {
    if (!_isValidPassword(newPassCtrl.text)) {
      _showSnack(context,
          "Password must be 6+ chars, with 1 uppercase, 1 number & 1 special character");
      return;
    }
    if (newPassCtrl.text != confPassCtrl.text) {
      _showSnack(context, "Passwords do not match");
      return;
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("FarmerEats", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 80),
              const Text("Reset Password",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              _buildField("New Password", Icons.lock_outline,
                  obscure: true, controller: newPassCtrl),
              const SizedBox(height: 15),
              _buildField("Confirm New Password", Icons.lock_outline,
                  obscure: true, controller: confPassCtrl),
              const SizedBox(height: 30),
              _buildPrimaryBtn("Submit", _submit),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. MULTI-STEP SIGNUP FLOW
// ==========================================
class SignupFlow extends StatefulWidget {
  const SignupFlow({super.key});
  @override
  State<SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<SignupFlow> {
  int _step = 0;
  bool _isLoading = false;
  bool _isFileAttached = false;
  DateTime? _lastPressedAt;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  final busNameCtrl = TextEditingController();
  final infoNameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final zipCtrl = TextEditingController();
  String selectedState = "State";

  List<String> activeDays = [];
  List<String> activeTimes = [];
  final days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
  final dayMapper = {
    'M': 'mon',
    'T': 'tue',
    'W': 'wed',
    'Th': 'thu',
    'F': 'fri',
    'S': 'sat',
    'Su': 'sun'
  };
  final times = [
    '8:00am - 10:00am',
    '10:00am - 1:00pm',
    '1:00pm - 4:00pm',
    '4:00pm - 7:00pm',
    '7:00pm - 10:00pm'
  ];

  // Indian States List
  final List<String> indianStates = [
    "State",
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Delhi",
    "Puducherry",
    "Chandigarh"
  ];

  // HARDWARE BACK BUTTON & DOUBLE TAP LOGIC
  Future<bool> _onWillPop() async {
    if (_step > 0) {
      setState(() => _step--);
      return false;
    } else {
      final now = DateTime.now();
      if (_lastPressedAt == null ||
          now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
        _lastPressedAt = now;
        _showSnack(context, "Press back again to exit", isError: false);
        return false;
      }
      return true;
    }
  }

  bool _validateStep() {
    if (_step == 0) {
      if (nameCtrl.text.trim().isEmpty ||
          emailCtrl.text.trim().isEmpty ||
          phoneCtrl.text.isEmpty ||
          passCtrl.text.isEmpty) {
        _showSnack(context, "All fields are required");
        return false;
      }
      if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(emailCtrl.text.trim())) {
        _showSnack(context, "Enter a valid email format");
        return false;
      }
      if (phoneCtrl.text.length != 10) {
        _showSnack(context, "Phone number must be exactly 10 digits");
        return false;
      }
      if (!_isValidPassword(passCtrl.text)) {
        _showSnack(context,
            "Password must be 6+ chars, with 1 uppercase, 1 number & 1 special character");
        return false;
      }
      if (passCtrl.text != confirmPassCtrl.text) {
        _showSnack(context, "Passwords do not match");
        return false;
      }
    } else if (_step == 1) {
      if (busNameCtrl.text.trim().isEmpty ||
          infoNameCtrl.text.trim().isEmpty ||
          addressCtrl.text.trim().isEmpty ||
          cityCtrl.text.trim().isEmpty ||
          zipCtrl.text.isEmpty ||
          selectedState == "State") {
        _showSnack(context, "Please fill in all Farm details");
        return false;
      }
      if (zipCtrl.text.length != 6) {
        _showSnack(context, "Pincode must be exactly 6 digits");
        return false;
      }
    } else if (_step == 2) {
      if (!_isFileAttached) {
        _showSnack(context, "Please attach proof of registration");
        return false;
      }
    } else if (_step == 3) {
      if (activeDays.isEmpty || activeTimes.isEmpty) {
        _showSnack(context, "Select at least one day and one time slot");
        return false;
      }
    }
    return true;
  }

  Future<void> _submitAPI() async {
    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://sowlab.com/assignment/user/register'));
      request.fields['full_name'] = nameCtrl.text.trim();
      request.fields['email'] = emailCtrl.text.trim();
      request.fields['phone'] = phoneCtrl.text;
      request.fields['password'] = passCtrl.text;
      request.fields['role'] = 'farmer';
      request.fields['business_name'] = busNameCtrl.text.trim();
      request.fields['informal_name'] = infoNameCtrl.text.trim();
      request.fields['address'] = addressCtrl.text.trim();
      request.fields['city'] = cityCtrl.text.trim();
      request.fields['state'] = selectedState;
      request.fields['zip_code'] = zipCtrl.text;
      request.fields['device_token'] = 'dummy_token';
      request.fields['type'] = 'email';
      request.fields['social_id'] = 'dummy_id';

      Map<String, List<String>> hoursMap = {};
      for (String d in activeDays) {
        hoursMap[dayMapper[d]!] = activeTimes;
      }
      request.fields['business_hours'] = jsonEncode(hoursMap);
      request.files.add(http.MultipartFile.fromString(
          'registration_proof', 'dummy file content',
          filename: 'usda_registration.pdf'));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200 && jsonResponse['success'] == "true") {
        if (mounted)
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const SuccessScreen()));
      } else {
        _showSnack(context, jsonResponse['message'] ?? "Registration Failed");
      }
    } on SocketException {
      _showSnack(context, "Network Error. Check your internet.");
    } catch (e) {
      _showSnack(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                  padding: EdgeInsets.only(left: 30, top: 20),
                  child: Text("FarmerEats", style: TextStyle(fontSize: 16))),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Signup ${_step + 1} of 4",
                          style: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Text(
                          _step == 0
                              ? "Welcome!"
                              : _step == 1
                                  ? "Farm Info"
                                  : _step == 2
                                      ? "Verification"
                                      : "Business Hours",
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      if (_step == 0) ...[
                        _buildSocialBtns(context),
                        const SizedBox(height: 20),
                        const Center(
                            child: Text("or signup with",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12))),
                        const SizedBox(height: 20),
                        _buildField("Full Name", Icons.person_outline,
                            controller: nameCtrl),
                        const SizedBox(height: 15),
                        _buildField("Email Address", Icons.alternate_email,
                            controller: emailCtrl, isEmail: true),
                        const SizedBox(height: 15),
                        _buildField("Phone Number", Icons.phone_outlined,
                            controller: phoneCtrl,
                            isPhone: true,
                            maxLength: 10),
                        const SizedBox(height: 15),
                        _buildField("Password", Icons.lock_outline,
                            obscure: true, controller: passCtrl),
                        const SizedBox(height: 15),
                        _buildField("Re-enter Password", Icons.lock_outline,
                            obscure: true, controller: confirmPassCtrl),
                      ],
                      if (_step == 1) ...[
                        _buildField("Business Name", Icons.sell_outlined,
                            controller: busNameCtrl),
                        const SizedBox(height: 15),
                        _buildField(
                            "Informal Name", Icons.emoji_emotions_outlined,
                            controller: infoNameCtrl),
                        const SizedBox(height: 15),
                        _buildField("Street Address", Icons.home_outlined,
                            controller: addressCtrl),
                        const SizedBox(height: 15),
                        _buildField("City", Icons.location_on_outlined,
                            controller: cityCtrl),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedState,
                                    isExpanded: true,
                                    items: indianStates
                                        .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s,
                                                overflow:
                                                    TextOverflow.ellipsis)))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => selectedState = v!),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                                child: _buildField("Pincode", null,
                                    controller: zipCtrl,
                                    isPhone: true,
                                    maxLength: 6)),
                          ],
                        ),
                      ],
                      if (_step == 2) ...[
                        const Text(
                            "Attached proof of Department of Agriculture registrations i.e. Florida Fresh, USDA Approved, USDA Organic",
                            style: TextStyle(color: Colors.grey, height: 1.5)),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Attach proof of registration",
                                style: TextStyle(fontSize: 16)),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _isFileAttached = true),
                              child: const CircleAvatar(
                                  backgroundColor: primaryColor,
                                  radius: 25,
                                  child: Icon(Icons.camera_alt_outlined,
                                      color: Colors.white)),
                            )
                          ],
                        ),
                        if (_isFileAttached) ...[
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("usda_registration.pdf",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline)),
                                GestureDetector(
                                    onTap: () =>
                                        setState(() => _isFileAttached = false),
                                    child: const Icon(Icons.close, size: 20)),
                              ],
                            ),
                          )
                        ]
                      ],
                      if (_step == 3) ...[
                        const Text(
                            "Choose the hours your farm is open for pickups. This will allow customers to order deliveries.",
                            style: TextStyle(color: Colors.grey, height: 1.5)),
                        const SizedBox(height: 30),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: days
                              .map((day) => GestureDetector(
                                    onTap: () => setState(() =>
                                        activeDays.contains(day)
                                            ? activeDays.remove(day)
                                            : activeDays.add(day)),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: activeDays.contains(day)
                                              ? primaryColor
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(day,
                                          style: TextStyle(
                                              color: activeDays.contains(day)
                                                  ? Colors.white
                                                  : Colors.black54,
                                              fontSize: 16)),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 30),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: times
                              .map((time) => GestureDetector(
                                    onTap: () => setState(() =>
                                        activeTimes.contains(time)
                                            ? activeTimes.remove(time)
                                            : activeTimes.add(time)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                      decoration: BoxDecoration(
                                          color: activeTimes.contains(time)
                                              ? activeYellow
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(time,
                                          style: const TextStyle(fontSize: 14)),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_step > 0) {
                          setState(() => _step--);
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        }
                      },
                      child: _step == 0
                          ? const Text("Login",
                              style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline))
                          : const Icon(Icons.arrow_back, size: 30),
                    ),
                    SizedBox(
                      width: 220,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_validateStep()) {
                                  if (_step < 3)
                                    setState(() => _step++);
                                  else
                                    _submitAPI();
                                }
                              },
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(_step == 3 ? "Signup" : "Continue",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. SUCCESS SCREEN
// ==========================================
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 120),
              const SizedBox(height: 30),
              const Text("You're all done!",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text(
                  "Hang tight! We are currently reviewing your account and will follow up with you in 2-3 business days.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.5)),
              const Spacer(),
              _buildPrimaryBtn(
                  "Got it!",
                  () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()))),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// REUSABLE UI & VALIDATION WIDGETS
// ==========================================
void _showSnack(BuildContext context, String msg, {bool isError = true}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green));
}

bool _isValidPassword(String password) {
  return RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{6,}$')
      .hasMatch(password);
}

Widget _buildField(String hint, IconData? icon,
    {bool obscure = false,
    bool showForgot = false,
    BuildContext? context,
    TextEditingController? controller,
    bool isPhone = false,
    bool isEmail = false,
    int? maxLength}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: isPhone
        ? TextInputType.number
        : (isEmail ? TextInputType.emailAddress : TextInputType.text),
    inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : null,
    maxLength: maxLength,
    decoration: InputDecoration(
      counterText: "",
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      suffixIcon: showForgot && context != null
          ? TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen())),
              child:
                  const Text("Forgot?", style: TextStyle(color: primaryColor)))
          : null,
    ),
  );
}

Widget _buildPrimaryBtn(String label, VoidCallback? onPressed,
    {bool isLoading = false}) {
  return SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      onPressed: onPressed,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
    ),
  );
}

Widget _buildSocialBtns(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _socialBtn(Icons.g_mobiledata, context, "Google"),
      _socialBtn(Icons.apple, context, "Apple"),
      _socialBtn(Icons.facebook, context, "Facebook"),
    ],
  );
}

Widget _socialBtn(IconData icon, BuildContext context, String name) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: Colors.grey[300]!)),
    onPressed: () =>
        _showSnack(context, "Connecting to $name...", isError: false),
    child: Icon(icon, color: Colors.black, size: 28),
  );
}
