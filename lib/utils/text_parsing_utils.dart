import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Utility class for parsing mentions and hashtags from text
class TextParsingUtils {
  /// Regular expression for matching @mentions
  /// Matches @username (alphanumeric and underscores)
  static final RegExp mentionRegex = RegExp(r'@([a-zA-Z0-9_]+)');

  /// Regular expression for matching #hashtags
  /// Matches #hashtag (alphanumeric and underscores)
  static final RegExp hashtagRegex = RegExp(r'#([a-zA-Z0-9_]+)');

  /// Extract all @mentions from text
  /// Returns list of usernames (without @ symbol)
  static List<String> extractMentions(String text) {
    if (text.isEmpty) return [];

    final matches = mentionRegex.allMatches(text);
    return matches.map((match) => match.group(1)!).toList();
  }

  /// Extract all #hashtags from text
  /// Returns list of hashtags (without # symbol)
  static List<String> extractHashtags(String text) {
    if (text.isEmpty) return [];

    final matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(1)!).toList();
  }

  /// Parse text with mentions and hashtags, making them tappable
  /// Returns a TextSpan with styled and tappable mentions/hashtags
  static TextSpan parseTextWithMentionsAndHashtags(
    String text, {
    TextStyle? baseStyle,
    TextStyle? mentionStyle,
    TextStyle? hashtagStyle,
    void Function(String)? onMentionTap,
    void Function(String)? onHashtagTap,
  }) {
    if (text.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    final spans = <InlineSpan>[];
    int lastMatchEnd = 0;

    // Create a list of all matches (mentions and hashtags) with their positions
    final allMatches = <_Match>[];

    // Add mention matches
    for (final match in mentionRegex.allMatches(text)) {
      allMatches.add(_Match(
        match.start,
        match.end,
        match.group(0)!,
        match.group(1)!,
        _MatchType.mention,
      ));
    }

    // Add hashtag matches
    for (final match in hashtagRegex.allMatches(text)) {
      allMatches.add(_Match(
        match.start,
        match.end,
        match.group(0)!,
        match.group(1)!,
        _MatchType.hashtag,
      ));
    }

    // Sort matches by start position
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    // Build TextSpan list
    for (final match in allMatches) {
      // Add normal text before this match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      // Add the match (mention or hashtag) as tappable
      if (match.type == _MatchType.mention) {
        spans.add(TextSpan(
          text: match.fullText,
          style: mentionStyle ??
              const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
          recognizer: onMentionTap != null
              ? (TapGestureRecognizer()
                ..onTap = () => onMentionTap(match.value))
              : null,
        ));
      } else {
        spans.add(TextSpan(
          text: match.fullText,
          style: hashtagStyle ??
              const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
          recognizer: onHashtagTap != null
              ? (TapGestureRecognizer()
                ..onTap = () => onHashtagTap(match.value))
              : null,
        ));
      }

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  /// Get a simple string with mentions and hashtags highlighted (for display)
  static String highlightMentionsAndHashtags(String text) {
    if (text.isEmpty) return text;

    String result = text;

    // This is just for display purposes, not actual linking
    // The actual linking is done in parseTextWithMentionsAndHashtags
    return result;
  }

  /// Validate if a string is a valid mention format
  static bool isValidMention(String text) {
    return mentionRegex.hasMatch(text) && text.startsWith('@');
  }

  /// Validate if a string is a valid hashtag format
  static bool isValidHashtag(String text) {
    return hashtagRegex.hasMatch(text) && text.startsWith('#');
  }

  /// Extract mentions and hashtags together
  static Map<String, List<String>> extractAll(String text) {
    return {
      'mentions': extractMentions(text),
      'hashtags': extractHashtags(text),
    };
  }

  /// Find the position of cursor within a mention or hashtag
  /// Returns the mention/hashtag being typed, or null
  static String? getCurrentTag(String text, int cursorPosition) {
    if (text.isEmpty || cursorPosition < 0 || cursorPosition > text.length) {
      return null;
    }

    // Find the word at cursor position
    int start = cursorPosition;
    int end = cursorPosition;

    // Find start of word
    while (start > 0 && !_isWhitespace(text[start - 1])) {
      start--;
    }

    // Find end of word
    while (end < text.length && !_isWhitespace(text[end])) {
      end++;
    }

    if (start >= end) return null;

    final word = text.substring(start, end);

    // Check if it's a mention or hashtag
    if (word.startsWith('@') || word.startsWith('#')) {
      return word;
    }

    return null;
  }

  /// Helper to check if character is whitespace
  static bool _isWhitespace(String char) {
    return char == ' ' || char == '\n' || char == '\t' || char == '\r';
  }
}

/// Internal class to represent a match (mention or hashtag)
class _Match {
  const _Match(
    this.start,
    this.end,
    this.fullText,
    this.value,
    this.type,
  );

  final int start;
  final int end;
  final String fullText; // e.g., "@john" or "#flutter"
  final String value; // e.g., "john" or "flutter"
  final _MatchType type;
}

/// Internal enum for match types
enum _MatchType {
  mention,
  hashtag,
}
