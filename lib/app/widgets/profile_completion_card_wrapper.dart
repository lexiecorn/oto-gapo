import 'package:flutter/material.dart';
import 'package:local_storage/local_storage.dart';
import 'package:otogapo/app/widgets/profile_completion_card.dart';

/// Wrapper widget that controls the visibility of ProfileCompletionCard
/// Shows the card only once a week to avoid being annoying
class ProfileCompletionCardWrapper extends StatefulWidget {
  const ProfileCompletionCardWrapper({super.key});

  @override
  State<ProfileCompletionCardWrapper> createState() =>
      _ProfileCompletionCardWrapperState();
}

class _ProfileCompletionCardWrapperState
    extends State<ProfileCompletionCardWrapper> {
  static const String _storageKey = 'profile_completion_card_last_shown';
  static const Duration _showInterval = Duration(days: 7); // Show once a week

  final LocalStorage _storage = const LocalStorage();
  bool _shouldShowCard = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkShouldShowCard();
  }

  Future<void> _checkShouldShowCard() async {
    try {
      final lastShown = await _storage.readWithTimestamp<bool>(_storageKey);

      if (lastShown == null || lastShown.value == null) {
        // Never shown before, show it now
        setState(() {
          _shouldShowCard = true;
          _isLoading = false;
        });
        await _updateLastShownTimestamp();
        return;
      }

      final lastShownTime = lastShown.value;
      if (lastShownTime == null) {
        // No timestamp, show it
        setState(() {
          _shouldShowCard = true;
          _isLoading = false;
        });
        await _updateLastShownTimestamp();
        return;
      }

      // Check if a week has passed
      final now = DateTime.now();
      final difference = now.difference(lastShownTime);

      if (difference >= _showInterval) {
        // More than a week has passed, show it again
        setState(() {
          _shouldShowCard = true;
          _isLoading = false;
        });
        await _updateLastShownTimestamp();
      } else {
        // Less than a week, don't show
        setState(() {
          _shouldShowCard = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking profile completion card visibility: $e');
      // On error, don't show the card to avoid annoyance
      setState(() {
        _shouldShowCard = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLastShownTimestamp() async {
    try {
      await _storage.writeWithTimestamp(_storageKey, true);
    } catch (e) {
      print('Error updating profile completion card timestamp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // While checking, return empty widget
      return const SizedBox.shrink();
    }

    if (!_shouldShowCard) {
      return const SizedBox.shrink();
    }

    // Show the card with an option to dismiss it manually
    return Stack(
      children: [
        const ProfileCompletionCard(),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _shouldShowCard = false;
              });
            },
          ),
        ),
      ],
    );
  }
}
