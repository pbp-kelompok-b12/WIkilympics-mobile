import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'poll_model.dart';
import 'poll_service.dart';
import 'package:wikilympics/widgets/left_drawer.dart';
import 'package:wikilympics/screens/login.dart';

class MyHomePage extends StatefulWidget {
    const MyHomePage({super.key});

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    PollQuestion? _poll;
    bool _showPopup = false;
    bool _hasVoted = false;
    bool _alreadyLoad = false;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        if (!_alreadyLoad) {
            _alreadyLoad = true;
            _loadPoll();
        }
    }

    Future<void> _loadPoll() async {
        final request = context.read<CookieRequest>();
        try {
            final data = await PollService.fetchPolls(request);
            if (data.isNotEmpty) {
                final poll = data[Random().nextInt(data.length)];
                setState(() {
                    _poll = poll;
                    _showPopup = true;
                });
            }
        } catch (_) {}
    }

    Future<void> _vote(int optionId) async {
      if (_hasVoted) return;
      final request = context.read<CookieRequest>();

      setState(() => _hasVoted = true);
      await PollService.vote(request, optionId);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _showPopup = false);
        }
      });
    }

    @override
    Widget build(BuildContext context) {
        final request = context.watch<CookieRequest>();
        final username = request.jsonData['username'];
        final greeting = username != null ? 'Hello, $username' : 'Hello';

        return Scaffold(
            backgroundColor: const Color(0xFFD6E4E5),
            appBar: AppBar(
                title: const Text("WIkilympics",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: const Color(0xFF01203F),
                actions: [
                    if (!request.loggedIn)
                        TextButton(
                            onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const LoginPage()));
                            },
                            child: const Text("Sign In", style: TextStyle(color: Colors.white)),
                        )
                ],
            ),
            drawer: const LeftDrawer(),
            body: Stack(
                children: [
                    _buildLandingContent(),
                    if (_showPopup && _poll != null) _buildPopup(greeting),
                ],
            ),
        );
    }

    Widget _buildLandingContent() {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                children: [
                    _heroSection(),
                    const SizedBox(height: 16),
                    _section("Popular Sports"),
                    _section("Athletes Highlight"),
                    _section("Upcoming Events"),
                    _section("Latest Articles"),
                    _section("Forum & Reviews"),
                ],
            ),
        );
    }

    Widget _heroSection() {
        return Column(
            children: [
                // Top white header background (logo Wikilympics)
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    color: Colors.white,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Image.asset(
                                'assets/wikilympics_banner.png',
                                height: 38,
                            ),
                            ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF01203F),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                ),
                                child: const Text(
                                    "SIGN IN",
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                ),
                            ),
                        ],
                    ),
                ),

                // Blue gradient hero container
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF01203F), Color(0xFF155F90)],
                        ),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(26),
                            bottomRight: Radius.circular(26),
                        ),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const SizedBox(height: 12),
                            Text(
                                "Discover the Spirit of Olympics",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                "Presented by B12",
                                style: GoogleFonts.poppins(
                                    color: Color(0xFFD9E74C),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        );
    }


    Widget _section(String t) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
        ),
        child: Text(t,
            style: GoogleFonts.poppins(
                color: const Color(0xFF01203F),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
    );

    Widget _buildPopup(String greeting) {
        final poll = _poll!;
        return Positioned.fill(
            child: Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => _showPopup = false),
                            ),
                        ),
                        Text(greeting,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF01203F))),
                        const SizedBox(height: 6),
                        Text(poll.questionText,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF155F90))),
                        const SizedBox(height: 14),
                        ...poll.options.map((o) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF01203F),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: _hasVoted ? null : () => _vote(o.id),
                                child: Text(o.optionText),
                            ),
                        )),
                        if (_hasVoted)
                            Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text("Terima kasih sudah memilih!",
                                    style: GoogleFonts.poppins(color: Colors.green)),
                            )
                    ]),
                ),
            ),
        );
    }
}
