import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String account = ''; // Placeholder for crypto wallet account address

  Future<void> _connectWallet() async {
    // WalletConnect logic or any wallet connection logic will be here
    setState(() {
      account = '0x1234567890abcdef'; // Dummy wallet address
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Wallet'),
      ),
      body: Center(
        child: account.isEmpty
            ? ElevatedButton(
                onPressed: _connectWallet,
                child: const Text('Connect Wallet'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Wallet Connected: $account'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/donate');
                    },
                    child: const Text('Proceed to Donate'),
                  ),
                ],
              ),
      ),
    );
  }
}
