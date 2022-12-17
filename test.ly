\version "2.16.0"

#(set-global-staff-size 20)

\include "center-note-column.ily"

\paper {
        ragged-right = ##f
}
%%{
% tiny example:

   <<
   \new Staff
   { \time 3/4 \key b\minor R2.*3 }
   \new Staff
   {
     \time 3/4 \key b\minor b''2.
     \key a\minor \onceCenterNoteColumn #0 <a'' bes''>2.
     \clef "treble" R
   }
   >>
%}
%%{
% full test:
\layout {
        %indent = 0
    \context {
      \Score
      \override NonMusicalPaperColumn.line-break-permission = ##f
      \override BarNumber.break-visibility = #'#(#t #t #t)
    }
    \context {
      \Staff
      %\remove Time_signature_engraver
      %\remove Key_engraver
      %\remove Clef_engraver
    }
}

\markup \vspace #2

testVoice = \relative c' {
        \key b\minor
        \time 3/4
        b'2_"Zeit?" r4
        \key g\minor
        \time 3/4
        \clef "bass"
        R2.
        \key a\minor
        \time 3/4
        \clef "treble"
        R2.
        \key g\minor
        \clef "bass"
        R2.
        \key a\minor
        \clef "treble"
%5
        R2. \break
        \key g\minor
        \clef "bass"
        R2.
        \key a\minor
        \clef "treble"
%7
        R2.
        \key g\minor
        \clef "bass"
        R2.*1\fermataMarkup
        \key a\minor
        \clef "treble"
        R
        \bar "|."
}

voice = \relative c' {
        \key b\minor
        \time 3/4
        b'2 r4
        R2.*6
        R2.*1\fermataMarkup
        R
        \bar "|."
}

pUp = \relative c' {
        \key b\minor
        \clef "bass"
        \time 3/4

%        \stemUp

        <d, fis b>2.\pp  (
        \centerNoteColumnOn
        \once \override Score.Arpeggio.padding = #-1.5
        \set Score.connectArpeggios = ##t
        <fis ais>\arpeggio
        <fis d'!>
        <e! g! c!>  )
%5
        \onceCenterNoteColumn #-0.4
        <dis fis! a b> (
        <e g b> )
%7
        <dis fis b> ~
        <dis fis b>\fermata
        r
}

pDown = \relative c' {
        \key b\minor
        \clef "bass"
        \time 3/4
        <b,, fis' b>2. ( |
        \centerNoteColumnOn
        <ais fis' ais>\arpeggio |
        <d fis d'>  |
        <c g' c> ) |
%5
\onceCenterNoteColumn #-0.4
        <b b'> ~ |
        <b b'>-.-> |
%7
        <b b'> ~ |
        <b b'>\fermata |
        r
}
\score {
  <<
    \new Staff %\voice
               \testVoice
    \new PianoStaff <<
        \new Staff <<
           \pUp
        >>
        \new Staff <<
           \pDown
        >>
        >>
  >>
  \layout {
    \context {
      \Score
      \remove "Bar_number_engraver"
    }
  }
}
%}
