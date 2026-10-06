import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The icon set used by the home screen, bottom bar and notifications,
/// redrawn to match the design: thin rounded "line" glyphs for the navigation
/// and header, solid "bold" glyphs (with real cut-outs, not white overlays)
/// for the cards, quick links and notification rows.
///
/// Every glyph is single-coloured: the SVG is painted in black and recoloured
/// at draw time with [AppSvgIcon.color], so it works on any background.
enum AppSvgGlyph {
  // Line glyphs.
  calendarLine(_calendarLine),
  documentLine(_documentLine),
  chatLine(_chatLine),
  userLine(_userLine),
  bellLine(_bellLine),
  pinLine(_pinLine),
  checkLine(_checkLine),
  backLine(_backLine),

  // Solid glyphs.
  homeBold(_homeBold),
  calendarBold(_calendarBold),
  calendarSearchBold(_calendarSearchBold),
  briefcaseBold(_briefcaseBold),
  noteBold(_noteBold),
  chatBold(_chatBold),
  chatsBold(_chatsBold),
  documentBold(_documentBold),
  infoBold(_infoBold),
  targetLine(_targetLine),
  chevronLine(_chevronLine),
  pinBold(_pinBold),
  homeLine(_homeLine),
  walletBold(_walletBold),
  usersBold(_usersBold),
  idCardBold(_idCardBold),
  stethoscope(_stethoscope),
  heartPlusBold(_heartPlusBold),
  videoBold(_videoBold),
  videoLine(_videoLine),
  clockBold(_clockBold),
  teamBold(_teamBold),
  chevronDown(_chevronDown),
  searchLine(_searchLine),
  globeBold(_globeBold),
  buildingBold(_buildingBold),
  pillsBold(_pillsBold),
  accessibilityBold(_accessibilityBold),
  phoneBold(_phoneBold),
  arrowSquareBold(_arrowSquareBold),
  userBold(_userBold),
  hexagonBold(_hexagonBold),
  calendarPlusBold(_calendarPlusBold),
  checkCircleBold(_checkCircleBold),
  documentUploadBold(_documentUploadBold);

  const AppSvgGlyph(this.markup);

  final String markup;
}

class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(this.glyph, {super.key, this.color, this.size = 24});

  final AppSvgGlyph glyph;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? Colors.black;
    return SvgPicture.string(
      glyph.markup,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
    );
  }
}

const _head = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">';
const _line =
    'fill="none" stroke="#000" stroke-width="1.5" stroke-linecap="round" '
    'stroke-linejoin="round"';

// ---- Line glyphs ----------------------------------------------------------

const _calendarLine =
    '$_head<g $_line>'
    '<path d="M8 3.2v2M16 3.2v2"/>'
    '<rect x="3.2" y="5.2" width="17.6" height="15.4" rx="4.6"/>'
    '<circle cx="16.4" cy="15" r="1.4"/>'
    '</g></svg>';

const _documentLine =
    '$_head<g $_line>'
    '<path d="M13.4 3.4H9A5.2 5.2 0 0 0 3.8 8.6v6.8A5.2 5.2 0 0 0 9 20.6h6'
    'a5.2 5.2 0 0 0 5.2-5.2V9.2"/>'
    '<path d="M13.4 3.4 20.2 9.2M13.4 3.4V6a3.2 3.2 0 0 0 3.2 3.2h3.6"/>'
    '<path d="M8 13.6h5.6M8 17h3.6"/>'
    '</g></svg>';

const _chatLine =
    '$_head<g $_line>'
    '<path d="M8.6 3.4h6.8a5 5 0 0 1 5 5v3.6a5 5 0 0 1-5 5h-1.2l-1.3 2.3'
    'a.9.9 0 0 1-1.6 0l-1.3-2.3H8.6a5 5 0 0 1-5-5V8.4a5 5 0 0 1 5-5Z"/>'
    '</g>'
    '<circle cx="8.4" cy="10.2" r="1" fill="#000"/>'
    '<circle cx="12" cy="10.2" r="1" fill="#000"/>'
    '<circle cx="15.6" cy="10.2" r="1" fill="#000"/>'
    '</svg>';

const _userLine =
    '$_head<g $_line>'
    '<circle cx="12" cy="12" r="9.2"/>'
    '<circle cx="12" cy="9.6" r="2.6"/>'
    '<path d="M6.8 18.2c.9-2.1 2.7-3.2 5.2-3.2s4.3 1.1 5.2 3.2"/>'
    '</g></svg>';

const _bellLine =
    '$_head<g $_line>'
    '<path d="M12 3.4c-3 0-5 2.2-5 5.1v2.1c0 .9-.4 1.8-1 2.5l-1.1 1.2'
    'c-.6.7-.1 1.8.8 1.8h12.6c.9 0 1.4-1.1.8-1.8L18 13.1c-.6-.7-1-1.6-1-2.5'
    'V8.5c0-2.9-2-5.1-5-5.1Z"/>'
    '<path d="M9.2 18.6c.5 1.2 1.5 1.9 2.8 1.9s2.3-.7 2.8-1.9"/>'
    '</g></svg>';

const _pinLine =
    '$_head<g $_line>'
    '<path d="M12 3.2c-3 0-5.2 2.3-5.2 5.2 0 3.3 3 5.8 5.2 7.4 2.2-1.6 5.2-4.1'
    ' 5.2-7.4 0-2.9-2.2-5.2-5.2-5.2Z"/>'
    '<circle cx="12" cy="8.5" r="1.9"/>'
    '<path d="M7.4 14.6C5.6 15.1 4.4 16 4.4 17c0 1.8 3.4 3.2 7.6 3.2'
    's7.6-1.4 7.6-3.2c0-1-1.2-1.9-3-2.4"/>'
    '</g></svg>';

const _checkLine =
    '$_head<path d="M4.5 12.6l5 5L19.5 6.6" fill="none" stroke="#000" '
    'stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';

const _backLine =
    '$_head<path d="M20 12H4.5M10.5 6l-6 6 6 6" fill="none" stroke="#000" '
    'stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';

const _targetLine =
    '$_head<g $_line>'
    '<circle cx="12" cy="12" r="4.4"/>'
    '<path d="M12 2.6v3M12 18.4v3M2.6 12h3M18.4 12h3"/>'
    '</g><circle cx="12" cy="12" r="1.6" fill="#000"/></svg>';

// ---- Solid glyphs ---------------------------------------------------------

const _homeBold =
    '$_head<path fill-rule="evenodd" d="M10.5 3.4a2.4 2.4 0 0 1 3 0l5.4 4.1'
    'c.7.5 1.1 1.3 1.1 2.2V17a3.6 3.6 0 0 1-3.6 3.6H7.6A3.6 3.6 0 0 1 4 17'
    'V9.7c0-.9.4-1.7 1.1-2.2Z'
    'M9.4 15.9a.7.7 0 0 0 0 1.4h5.2a.7.7 0 0 0 0-1.4Z"/></svg>';

// Calendar: tick marks, header block, divider gap, body with a dot cut-out.
const _calendarBold =
    '$_head<path d="M8 2.6v2.4M16 2.6v2.4" stroke="#000" stroke-width="1.6" '
    'stroke-linecap="round" fill="none"/>'
    '<path d="M3 9V8.6A3.6 3.6 0 0 1 6.6 5h10.8A3.6 3.6 0 0 1 21 8.6V9Z"/>'
    '<path fill-rule="evenodd" d="M3 10.4h18v6A4.6 4.6 0 0 1 16.4 21H7.6'
    'A4.6 4.6 0 0 1 3 16.4Z'
    'M16.5 14.6a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3Z"/></svg>';

const _calendarSearchBold =
    '$_head<path d="M8 2.6v2.4M16 2.6v2.4" stroke="#000" stroke-width="1.6" '
    'stroke-linecap="round" fill="none"/>'
    '<path d="M3 9V8.6A3.6 3.6 0 0 1 6.6 5h10.8A3.6 3.6 0 0 1 21 8.6V9Z"/>'
    '<path d="M3 10.4h18v4.4A5.2 5.2 0 1 0 12.85 21H7.6A4.6 4.6 0 0 1 3 16.4Z"/>'
    '<g fill="none" stroke="#000" stroke-width="1.7" stroke-linecap="round">'
    '<circle cx="16.4" cy="17.2" r="3.3"/>'
    '<path d="M19 19.8l1.9 1.9"/></g></svg>';

const _briefcaseBold =
    '$_head<path d="M8.9 7V5.8A1.8 1.8 0 0 1 10.7 4h2.6a1.8 1.8 0 0 1 1.8 1.8V7"'
    ' stroke="#000" stroke-width="1.8" stroke-linecap="round" fill="none"/>'
    '<path fill-rule="evenodd" d="M3 11a3.8 3.8 0 0 1 3.8-3.8h10.4A3.8 3.8 0 0 1'
    ' 21 11v3.3c0 .8-.7 1.4-1.5 1.3-5-1-10-1-15 0-.8.1-1.5-.5-1.5-1.3Z'
    'M12 10.4a1.3 1.3 0 1 0 0 2.6 1.3 1.3 0 0 0 0-2.6Z"/>'
    '<path d="M4.3 17.4c5.1-1 10.3-1 15.4 0v.7A3.3 3.3 0 0 1 16.4 21.4H7.6'
    'a3.3 3.3 0 0 1-3.3-3.3Z"/></svg>';

const _noteBold =
    '$_head<path fill-rule="evenodd" d="M8.6 3.4h6.8a5.2 5.2 0 0 1 5.2 5.2v6.8'
    'a5.2 5.2 0 0 1-5.2 5.2H8.6a5.2 5.2 0 0 1-5.2-5.2V8.6A5.2 5.2 0 0 1 8.6 3.4Z'
    'M8.2 9.3h7.6a.75.75 0 0 1 0 1.5H8.2a.75.75 0 0 1 0-1.5Z'
    'M8.2 13.2h4.6a.75.75 0 0 1 0 1.5H8.2a.75.75 0 0 1 0-1.5Z"/></svg>';

const _chatBold =
    '$_head<path fill-rule="evenodd" d="M8.6 3.8h6.8a4.8 4.8 0 0 1 4.8 4.8v3.6'
    'a4.8 4.8 0 0 1-4.8 4.8h-1.3l-1.3 2.4a.9.9 0 0 1-1.6 0l-1.3-2.4H8.6'
    'a4.8 4.8 0 0 1-4.8-4.8V8.6a4.8 4.8 0 0 1 4.8-4.8Z'
    'M8.4 9.3a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z'
    'M12 9.3a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z'
    'M15.6 9.3a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z"/></svg>';

const _chatsBold =
    '$_head<path d="M11.7 4.4A5.8 5.8 0 0 1 19.3 13.1'
    'A9.3 9.3 0 0 0 11.7 4.4Z"/>'
    '<path d="M18.6 12.4l.7 1.7a.8.8 0 0 1-.9 1.1l-1.6-.4Z"/>'
    '<path fill-rule="evenodd" d="M3.5 17.3A7.5 7.5 0 1 1 7.4 20.6L4.7 21.2'
    'C3.5 21.3 3.2 20.6 3.4 19.8Z'
    'M7 12.6a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z'
    'M10 12.6a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z'
    'M13 12.6a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z"/></svg>';

const _documentBold =
    '$_head<path d="M13.6 3.8 20 9H17a3.4 3.4 0 0 1-3.4-3.4Z"/>'
    '<path fill-rule="evenodd" d="M8.6 3.4h3.2v2.2a4 4 0 0 0 4 4H20.6v5.8'
    'a5.2 5.2 0 0 1-5.2 5.2H8.6a5.2 5.2 0 0 1-5.2-5.2V8.6A5.2 5.2 0 0 1 8.6 3.4Z'
    'M8.2 13.4h5.6a.7.7 0 0 1 0 1.4H8.2a.7.7 0 0 1 0-1.4Z'
    'M8.2 16.6h3.6a.7.7 0 0 1 0 1.4H8.2a.7.7 0 0 1 0-1.4Z"/></svg>';

const _infoBold =
    '$_head<path fill-rule="evenodd" d="M12 2.8a9.2 9.2 0 1 0 0 18.4 9.2 9.2 0 0 0'
    ' 0-18.4Zm0 4.2a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2Zm-1 4.2a1 1 0 0 1'
    ' 2 0v5a1 1 0 0 1-2 0Z"/></svg>';

const _chevronLine =
    '$_head<path d="M9 5l7 7-7 7" fill="none" stroke="#000" stroke-width="1.6" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>';

const _pinBold =
    '$_head<path fill-rule="evenodd" d="M12 2.6a6.6 6.6 0 0 0-6.6 6.6c0 4.3 4 '
    '8.2 5.9 11.6a.8.8 0 0 0 1.4 0c1.9-3.4 5.9-7.3 5.9-11.6A6.6 6.6 0 0 0 12 '
    '2.6Zm0 4.4a2.3 2.3 0 1 1 0 4.6 2.3 2.3 0 0 1 0-4.6Z"/></svg>';

const _homeLine =
    '$_head<g $_line>'
    '<path d="M10.6 4a2.2 2.2 0 0 1 2.8 0l5.3 4c.7.5 1.1 1.2 1.1 2V17a3.5 3.5 '
    '0 0 1-3.5 3.5H7.7A3.5 3.5 0 0 1 4.2 17v-7c0-.8.4-1.5 1.1-2Z"/>'
    '<path d="M9.8 16.6h4.4"/></g></svg>';

const _walletBold =
    '$_head<path d="M6.5 6.4 13 3.6a1.1 1.1 0 0 1 1.5 1V6.4Z"/>'
    '<path fill-rule="evenodd" d="M3 10.2a3.8 3.8 0 0 1 3.8-3.8h10.4A3.8 3.8 0 '
    '0 1 21 10.2v7A3.8 3.8 0 0 1 17.2 21H6.8A3.8 3.8 0 0 1 3 17.2Z'
    'M6.2 9.3a.7.7 0 0 0 0 1.4h3a.7.7 0 0 0 0-1.4Z'
    'M21 12.2h-5.6a2.4 2.4 0 0 0 0 4.8H21Z'
    'M15.4 13.6a1 1 0 1 0 0 2 1 1 0 0 0 0-2Z"/></svg>';

const _usersBold =
    '$_head<circle cx="12" cy="6.4" r="3"/><circle cx="4.9" cy="9.6" r="2.2"/>'
    '<circle cx="19.1" cy="9.6" r="2.2"/>'
    '<path d="M6.4 19.2c0-3.4 2.4-5.6 5.6-5.6s5.6 2.2 5.6 5.6c0 1-.7 1.6-1.7 '
    '1.6H8.1c-1 0-1.7-.6-1.7-1.6Z"/>'
    '<path d="M1.6 17.4c0-2.3 1.4-3.8 3.4-3.8l.7.1c-1 1.1-1.5 2.4-1.5 4v.4H3'
    'c-.8 0-1.4-.3-1.4-.7Z"/>'
    '<path d="M22.4 17.4c0-2.3-1.4-3.8-3.4-3.8l-.7.1c1 1.1 1.5 2.4 1.5 4v.4H21'
    'c.8 0 1.4-.3 1.4-.7Z"/></svg>';

const _idCardBold =
    '$_head<path fill-rule="evenodd" d="M6.4 4.6h11.2A4 4 0 0 1 21.6 8.6v6.8'
    'a4 4 0 0 1-4 4H6.4a4 4 0 0 1-4-4V8.6a4 4 0 0 1 4-4Z'
    'M8.4 8.2a1.9 1.9 0 1 0 0 3.8 1.9 1.9 0 0 0 0-3.8Z'
    'M5.2 15.6c0-1.4 1.4-2.3 3.2-2.3s3.2.9 3.2 2.3c0 .5-.4.8-.9.8H6.1'
    'c-.5 0-.9-.3-.9-.8Z'
    'M13.6 8.2h4.4a.65.65 0 0 1 0 1.3h-4.4a.65.65 0 0 1 0-1.3Z'
    'M13.6 11.3h4.4a.65.65 0 0 1 0 1.3h-4.4a.65.65 0 0 1 0-1.3Z'
    'M13.6 14.4h2.6a.65.65 0 0 1 0 1.3h-2.6a.65.65 0 0 1 0-1.3Z"/></svg>';

const _stethoscope =
    '$_head<g fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" '
    'stroke-linejoin="round">'
    '<path d="M5.4 2.8v5.6a4.6 4.6 0 0 0 9.2 0V2.8"/>'
    '<path d="M10 13v2.4a4.2 4.2 0 0 0 8.4 0v-1.2"/></g>'
    '<circle cx="18.4" cy="12.4" r="2.5"/></svg>';

const _heartPlusBold =
    '$_head<path fill-rule="evenodd" d="M12 21.3C5.4 16.2 2.4 12.8 2.4 9'
    'a5 5 0 0 1 9.6-2 5 5 0 0 1 9.6 2c0 3.8-3 7.2-9.6 12.3Z'
    'M15.2 6.6a.75.75 0 0 0-.75.75v1.6h-1.6a.75.75 0 0 0 0 1.5h1.6v1.6'
    'a.75.75 0 0 0 1.5 0v-1.6h1.6a.75.75 0 0 0 0-1.5h-1.6v-1.6a.75.75 0 0 0'
    '-.75-.75Z"/></svg>';

const _videoBold =
    '$_head<path d="M6 5.8h6.4A3.6 3.6 0 0 1 16 9.4v5.2a3.6 3.6 0 0 1-3.6 3.6H6'
    'a3.6 3.6 0 0 1-3.6-3.6V9.4A3.6 3.6 0 0 1 6 5.8Z"/>'
    '<path d="M17.6 10.6l3.1-1.9a.8.8 0 0 1 1.2.7v5.2a.8.8 0 0 1-1.2.7l-3.1-1.9Z"/>'
    '</svg>';

const _videoLine =
    '$_head<g $_line>'
    '<path d="M6 5.8h6.4A3.6 3.6 0 0 1 16 9.4v5.2a3.6 3.6 0 0 1-3.6 3.6H6'
    'a3.6 3.6 0 0 1-3.6-3.6V9.4A3.6 3.6 0 0 1 6 5.8Z"/>'
    '<path d="M16 11l4.4-2.6a.6.6 0 0 1 .9.5v6.2a.6.6 0 0 1-.9.5L16 13Z"/>'
    '</g></svg>';

const _clockBold =
    '$_head<path fill-rule="evenodd" d="M12 2.8a9.2 9.2 0 1 0 0 18.4 9.2 9.2 0 '
    '0 0 0-18.4Zm-.8 4.2a.8.8 0 0 1 1.6 0v4.7l2.9 1.9a.8.8 0 1 1-.9 1.3'
    'l-3.3-2.1a.9.9 0 0 1-.3-.7Z"/></svg>';

const _teamBold =
    '$_head<circle cx="7.4" cy="6.8" r="3.4"/>'
    '<path d="M13.2 3.6a3.4 3.4 0 0 1 0 6.4 4.4 4.4 0 0 0 0-6.4Z"/>'
    '<ellipse cx="8.4" cy="17.4" rx="6" ry="3.4"/>'
    '<path d="M15.6 14.2c3.2.2 5.4 1.6 5.4 3.2s-2.2 3-5.4 3.2c1.6-.8 2.6-1.9 '
    '2.6-3.2s-1-2.4-2.6-3.2Z"/></svg>';

const _chevronDown =
    '$_head<path d="M6 9l6 6 6-6" fill="none" stroke="#000" stroke-width="1.8" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>';

const _searchLine =
    '$_head<g $_line><circle cx="11" cy="11" r="7.2"/><path d="M16.4 16.4l4.2 4.2"/>'
    '</g></svg>';

const _globeBold =
    '$_head<g fill="none" stroke="#000" stroke-width="2" stroke-linecap="round">'
    '<circle cx="12" cy="12" r="8.8"/>'
    '<ellipse cx="12" cy="12" rx="3.8" ry="8.8"/>'
    '<path d="M3.2 12h17.6"/></g></svg>';

const _buildingBold =
    '$_head<path fill-rule="evenodd" d="M7 2.8h10a2 2 0 0 1 2 2V21H5V4.8a2 2 0 '
    '0 1 2-2Z'
    'M11.3 4.8h1.4v1.6h1.6v1.4h-1.6v1.6h-1.4V7.8H9.7V6.4h1.6Z'
    'M7.4 11h2.4v1.8H7.4Zm3.4 0h2.4v1.8h-2.4Zm3.4 0h2.4v1.8h-2.4Z'
    'M7.4 14.4h2.4v1.8H7.4Zm3.4 0h2.4v1.8h-2.4Zm3.4 0h2.4v1.8h-2.4Z'
    'M10.4 18h3.2v3h-3.2Z"/></svg>';

const _pillsBold =
    '$_head<g transform="rotate(-45 12 12)">'
    '<path d="M7.2 7.6h4.2v8.8H7.2a4.4 4.4 0 0 1 0-8.8Z"/>'
    '<path d="M12.6 7.6h4.2a4.4 4.4 0 0 1 0 8.8h-4.2Z"/></g></svg>';

const _accessibilityBold =
    '$_head<path fill-rule="evenodd" d="M12 2.2a9.8 9.8 0 1 0 0 19.6 9.8 9.8 0 '
    '0 0 0-19.6Zm0 3.4a1.6 1.6 0 1 1 0 3.2 1.6 1.6 0 0 1 0-3.2Zm-4.4 4.4h8.8'
    'a.8.8 0 0 1 0 1.6h-2.8v2.2l1.7 3.4a.8.8 0 0 1-1.4.7L12 15.6l-1.9 2.3'
    'a.8.8 0 0 1-1.4-.7l1.7-3.4v-2.2H7.6a.8.8 0 0 1 0-1.6Z"/></svg>';

const _phoneBold =
    '$_head<path d="M6.6 10.8c1.4 2.8 3.8 5.1 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 '
    '1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1C9.6 21 2 13.4 2 4c0-.6.4'
    '-1 1-1h3.5c.6 0 1 .4 1 1 0 1.2.2 2.4.6 3.6.1.4 0 .7-.3 1Z"/></svg>';

const _arrowSquareBold =
    '$_head<path fill-rule="evenodd" d="M7 2h10a5 5 0 0 1 5 5v10a5 5 0 0 1-5 5H7'
    'a5 5 0 0 1-5-5V7a5 5 0 0 1 5-5Zm8.6 6.4H9.8a.8.8 0 0 0 0 1.6h3.7l-5.2 5.2'
    'a.8.8 0 1 0 1.1 1.1l5.2-5.2v3.7a.8.8 0 0 0 1.6 0V9.2a.8.8 0 0 0-.6-.8Z"/>'
    '</svg>';

const _userBold =
    '$_head<circle cx="12" cy="7.2" r="4"/>'
    '<path d="M4.2 19.4c0-3.4 3.4-5.6 7.8-5.6s7.8 2.2 7.8 5.6c0 1-.8 1.8-1.8 1.8'
    'H6c-1 0-1.8-.8-1.8-1.8Z"/></svg>';

const _hexagonBold =
    '$_head<path fill-rule="evenodd" d="M10.6 2.6a2.8 2.8 0 0 1 2.8 0l6.4 3.7'
    'a2.8 2.8 0 0 1 1.4 2.4v6.6a2.8 2.8 0 0 1-1.4 2.4l-6.4 3.7a2.8 2.8 0 0 1-2.8 0'
    'l-6.4-3.7a2.8 2.8 0 0 1-1.4-2.4V8.7a2.8 2.8 0 0 1 1.4-2.4Z'
    'M12 8.8a3.2 3.2 0 1 0 0 6.4 3.2 3.2 0 0 0 0-6.4Z"/></svg>';

const _calendarPlusBold =
    '$_head<path d="M8 2.6v2.4M16 2.6v2.4" stroke="#000" stroke-width="1.6" '
    'stroke-linecap="round" fill="none"/>'
    '<path d="M3 9V8.6A3.6 3.6 0 0 1 6.6 5h10.8A3.6 3.6 0 0 1 21 8.6V9Z"/>'
    '<path fill-rule="evenodd" d="M3 10.4h18v6A4.6 4.6 0 0 1 16.4 21H7.6'
    'A4.6 4.6 0 0 1 3 16.4Z'
    'M12 12.8a.7.7 0 0 0-.7.7v1.5H9.8a.7.7 0 0 0 0 1.4h1.5v1.5a.7.7 0 0 0 1.4 0'
    'v-1.5h1.5a.7.7 0 0 0 0-1.4h-1.5v-1.5a.7.7 0 0 0-.7-.7Z"/></svg>';

const _checkCircleBold =
    '$_head<path fill-rule="evenodd" d="M12 2.8a9.2 9.2 0 1 0 0 18.4 9.2 9.2 0 0 0'
    ' 0-18.4Zm4.2 6.9a.8.8 0 0 1 0 1.1l-4.6 4.6a.8.8 0 0 1-1.1 0l-2.2-2.2'
    'a.8.8 0 1 1 1.1-1.1l1.7 1.7 4-4a.8.8 0 0 1 1.1 0Z"/></svg>';

const _documentUploadBold =
    '$_head<path d="M13.6 3.8 20 9H17a3.4 3.4 0 0 1-3.4-3.4Z"/>'
    '<path fill-rule="evenodd" d="M8.6 3.4h3.2v2.2a4 4 0 0 0 4 4H20.6v5.8'
    'a5.2 5.2 0 0 1-5.2 5.2H8.6a5.2 5.2 0 0 1-5.2-5.2V8.6A5.2 5.2 0 0 1 8.6 3.4Z'
    'M11.2 17.6a.7.7 0 0 0 1.4 0v-3l.8.8a.7.7 0 1 0 1-1l-2-2a.7.7 0 0 0-1 0l-2 2'
    'a.7.7 0 1 0 1 1l.8-.8Z"/></svg>';
