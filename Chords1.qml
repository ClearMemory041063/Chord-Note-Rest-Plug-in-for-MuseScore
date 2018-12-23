// Chords1.qml
// 22 Dec 2018
// Joe McCarty
// Musescore v2.3.4 rev4592407
// This program creates a new chord 
// based on a scale type, starting note, octave and
// selected note timing of 1/32, 1/16, 1/8, 1/4, 1/2 or whole 
// note

// import modules
import MuseScore 1.0
import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.0

// the plugin code begins here
MuseScore {
 version: "1.0.0"
 menuPath: "Plugins.Chords1" // addin location
 description: "Creates chord"
// pluginType: "dialog"

// function to display an error message dialog 
 function error(errorMessage) {
  errorDialog.text = qsTr(errorMessage)
  errorDialog.open()
 }//end error

// data to supply numerator, denominator
 property var notetime:[ 
//numerator,denominator
  [1,32],
  [1,16],
  [1,8],
  [1,4],
  [1,2],
  [1,1]
 ]; 
///chord data table contains midi note numbers (do not sort)
 property var chords:[
  [60, 64, 68] ,//  +5 
  [60] ,//  1 
  [60, 64, 67, 70, 74, 77] ,//  11 
  [60, 64, 67, 70, 74, 78] ,//  11+ 
  [60, 64, 67, 70, 74, 77, 81] ,//  13 
  [60, 67] ,//  5 
  [60, 64, 67, 69] ,//  6 
  [60, 64, 67, 69, 74] ,//  6*9 
  [60, 64, 67, 70] ,//  7 
  [60, 64, 68, 70] ,//  7+5 
  [60, 64, 68, 70, 73] ,//  7+5-9 
  [60, 64, 67, 70, 75] ,//  7-10 
  [60, 64, 67, 70, 76] ,//  7-11 
  [60, 64, 67, 70, 80] ,//  7-13 
  [60, 64, 66, 70] ,//  7-5 
  [60, 64, 67, 70, 73] ,//  7-9 
  [60, 62, 67, 70] ,//  7sus2 
  [60, 65, 67, 70] ,//  7sus4 
  [60, 64, 67, 70, 74] ,//  9 
  [60, 70, 73] ,//  9+5 
  [60, 65, 67, 70, 74] ,//  9sus4 
  [60, 64, 67] ,//  M 
  [60, 64, 67, 71] ,//  M7 
  [60, 64, 68] ,//  a 
  [60, 64, 67, 77] ,//  add11 
  [60, 64, 67, 81] ,//  add13 
  [60, 62, 64, 67] ,//  add2 
  [60, 64, 65, 67] ,//  add4 
  [60, 64, 67, 74] ,//  add9 
  [60, 64, 68] ,//  augmented 
  [60, 63, 66] ,//  dim 
  [60, 63, 66, 69] ,//  dim7 
  [60, 63, 66] ,//  diminished 
  [60, 63, 66, 69] ,//  diminished7 
  [60, 64, 67, 70] ,//  dom7 
  [60, 63, 66, 70] ,//  halfdim 
  [60, 63, 66, 70] ,//  halfdiminished 
  [60, 63, 66] ,//  i 
  [60, 63, 66, 69] ,//  i7 
  [60, 63, 67] ,//  m 
  [60, 63, 68] ,//  m+5 
  [60, 63, 67, 70, 74, 77] ,//  m11 
  [60, 63, 67, 70, 74, 78] ,//  m11+ 
  [60, 63, 67, 70, 74, 77, 81] ,//  m13 
  [60, 63, 67, 69] ,//  m6 
  [60, 63, 69, 67, 74] ,//  m6*9 
  [60, 63, 67, 70] ,//  m7 
  [60, 63, 68, 70] ,//  m7+5 
  [60, 63, 68, 70, 73] ,//  m7+5-9 
  [60, 63, 67, 70, 74] ,//  m7+9 
  [60, 63, 66, 70] ,//  m7-5 
  [60, 63, 67, 70, 73] ,//  m7-9 
  [60, 63, 66, 70] ,//  m7b5 
  [60, 63, 67, 70, 74] ,//  m9 
  [60, 70, 74] ,//  m9+5 
  [60, 63, 67, 77] ,//  madd11 
  [60, 63, 67, 81] ,//  madd13 
  [60, 62, 63, 67] ,//  madd2 
  [60, 63, 65, 67] ,//  madd4 
  [60, 63, 67, 74] ,//  madd9 
  [60, 64, 67] ,//  maj 
  [60, 64, 67, 71, 74, 77] ,//  maj11 
  [60, 64, 67, 71, 74] ,//  maj9 
  [60, 64, 67] ,//  major 
  [60, 64, 67, 71] ,//  major7 
  [60, 63, 67] ,//  min 
  [60, 63, 67] ,//  minor 
  [60, 63, 67, 70] ,//  minor7 
  [60, 62, 67] ,//  sus2 
  [60, 65, 67] ,//  sus4 
 ];//end chords table
//
 function setCursorToTime(cursor, time){
  cursor.rewind(0);
  while (cursor.segment) { 
   var current_time = cursor.tick;
   if(current_time>=time){
    return true;
   }//endif
   cursor.next();
  }//end while
  cursor.rewind(0);
  return false;
 }//end setCursorTo Time

// function to create and return a new Note element with given (midi) pitch, tpc1, tpc2 and headtype
 function createNote(pitch, tpc1, tpc2, head){
  var note = newElement(Element.NOTE);
  console.log("pitch= ",pitch);
  note.pitch = pitch;
  var pitch_mod12 = pitch%12; 
  var pitch2tpc=[14,21,16,23,18,13,20,15,22,17,24,19]; //get tpc from pitch... yes there is a logic behind these numbers :-p
  if (tpc1){
   note.tpc1 = tpc1;
   note.tpc2 = tpc2;
  }else{
   note.tpc1 = pitch2tpc[pitch_mod12];
   note.tpc2 = pitch2tpc[pitch_mod12];
  }//endif
  if (head) note.headType = head; 
  else note.headType = NoteHead.HEAD_AUTO;
   console.log("  created note with tpc: ",note.tpc1," ",note.tpc2," pitch: ",note.pitch);
  return note;
 }//end createNote  
  function copyarray(a){
   var b=[];
   for(var i=0;i<a.length;i++) b.push(a[i]);
   return b;
  }//end copyarray

  function invertChord(a,n){
   var b=[];
   var i;
   var c;
   var d=[];
   if (n>=0){
    b=copyarray(a);
    i=0;
    while (i<n){
      c=b[0];
      b=b.slice(1,b.length);
      b.push(c+12);
      i+=1;
    }//end while
    return b;
   }//end if
   n=-n;
   b=copyarray(a);
   i=0;
   while (i<n){
    c=b.pop();
    d=[];
    d.push(c-12);
for(var j=0;j<b.length;j++) d.push(b[j]);
    b=copyarray(d)//d.flatten;
    i+=1;
   }//end while
   return b;
  }//end invertChord

// global variables to allow apply to repeat
 property var rflag: false
 property var cursor: 0
 property var cscore: 0 

// Apply the given function to all notes in selection
// or, if nothing is selected, in the entire score
 function apply(){
  var nt=[1,1];
  var st;
  var pn;
  var oct;
  var inv;
  var slen; 
  var i=0;
  var staff=0;
  var voice=0;
  var next_time;
  var chord; 
  var cur_time;
  var rest; 
  var startStaff;
  var endStaff;
  var endTick;
  var ichord;
  var fullScore = false;
  cscore=curScore;
  cscore.startCmd();

  if(!rflag){ // do this on first call
   cscore=curScore;
   cursor = curScore.newCursor();
   cursor.rewind(1);
   cursor = curScore.newCursor();
   cursor.rewind(1);
   if (!cursor.segment) { // no selection
    fullScore = true;
    startStaff = 0; // start with 1st staff
    endStaff = curScore.nstaves - 1; // and end with last
   } else {
    startStaff = cursor.staffIdx;
    cursor.rewind(2);
    if (cursor.tick == 0) {
// this happens when the selection includes
// the last measure of the score.
// rewind(2) goes behind the last segment (where
// there's none) and sets tick=0
     endTick = curScore.lastSegment.tick + 1;
    } else {
     endTick = cursor.tick;
    }//end if cursor.tick
    endStaff = cursor.staffIdx;
   }//end cursor.segment
   console.log(startStaff + " - " + endStaff + " - " + endTick)
   staff=startStaff
   voice=0;
   cursor.rewind(1); // sets voice to 0
   cursor.voice = voice; //voice has to be set after goTo
   cursor.staffIdx = staff; //staff 0=treble, 1=bass
   if (fullScore)cursor.rewind(0) // if no selection, beginning of score
   rflag=true;
  }//end if !rflag
/// this code runs for all calls to apply
// get data from interface widgets
  nt=notetime[noteType.model.get(noteType.currentIndex).note];
  st=chordType.model.get(chordType.currentIndex).note
  pn=pivotNote.model.get(pivotNote.currentIndex).note;
  oct=octave.model.get(octave.currentIndex).note;
  inv=cInversion.model.get(cInversion.currentIndex).note;
// now work with it
  if(st> -1){
ichord=invertChord(chords[st],inv);
   slen=ichord.length;
   cur_time=cursor.tick;
   cursor.setDuration(nt[0],nt[1]);
///
// if (cursor.element.type == Element.CHORD) //console.log("CHORD");
// if (cursor.element.type == Element.REST) console.log("REST");
///
// https://github.com/musescore/MuseScore/tree/master/libmscore
//console.log("Element duration //",chord.duration.numerator,chord.duration.denominator);
///
   cursor.addNote(ichord[0]+pn+(oct-3)*12); //add 1st note
   next_time=cursor.tick;
   setCursorToTime(cursor, cur_time); //rewind to this note
//get the chord created when 1st note was inserted
   chord = cursor.element; 
   for(var i=1; i<ichord.length; i++){
   //add notes to the chord
    chord.add(createNote(ichord[i]+pn+(oct-3)*12)); 
   }//next i
   setCursorToTime(cursor, next_time);
  }else{ // add a rest
   // add a note to beep
   cur_time=cursor.tick;
   cursor.setDuration(nt[0],nt[1]);
   cursor.addNote(60); //add 1st note
   next_time=cursor.tick;
   setCursorToTime(cursor, cur_time); //rewind to this note
   //replace note with rest
   rest = newElement(Element.REST);
   rest.durationType = cursor.element.durationType;
   rest.duration = cursor.element.duration;cursor.add(rest);
   cursor.next();
  }//end if st> -1 else
  cscore.endCmd();
 }//end apply function

 onRun: {
  // move myWindow from center to the right
  myWindow.x=myWindow.x * 1.5;
  rflag=false
  if (typeof curScore === 'undefined')Qt.quit();
 }//end onRun

/// http://doc.qt.io/qt-5/qml-qtquick-window-window.html
 Window {
  id: myWindow
  title: "Notes, Chords and Rests"
  width: 300
  height: 400 
  flags:  Qt.Window |Qt.WindowStaysOnTopHint|Qt.WindowTitleHint 
// possible flags
 //   flags:  Qt.Window | Qt.WindowSystemMenuHint
 //           | Qt.WindowTitleHint | Qt.WindowMinimizeButtonHint
 //  | Qt.WindowMaximizeButtonHint |    Qt.WindowStaysOnTopHint
  visible: true
  // rectangle for display and the widgets inside
  Rectangle {
   color: "lightgrey"
   anchors.fill: parent
 
  GridLayout {
id: gl1
    columns: 2
    anchors.fill: parent
    anchors.margins: 10
//////////////
    Label {
     text: "Chord Type"
    }//end label

    ComboBox {
     id: chordType
     width:100
     Layout.fillWidth:	true
     model: ListModel {
      id: chordTypeList
      // note values are index into chords array 
      ListElement { text:"Rest"; note:  -1;}  
      ListElement { text:"Note"; note:  1;}  
      ListElement { text:"5"; note:  5;} 
// You may edit the order of this list to move
// frequently used chord types to the top
      ListElement { text:"major"; note:  63;}  
      ListElement { text:"minor"; note:  66;}  
      ListElement { text:"major7"; note:  64;}  
      ListElement { text:"minor7"; note:  67;}  
      ListElement { text:"augmented"; note:  29;}  

      ListElement { text:"diminished"; note:  32;}  
      ListElement { text:"diminished7"; note:  33;}  

      ListElement { text:"11"; note:  2;}  
      ListElement { text:"11+"; note:  3;}  
      ListElement { text:"13"; note:  4;}  
     //  ListElement { text:"+5"; note:  0;}  
      ListElement { text:"6"; note:  6;}  
      ListElement { text:"6*9"; note:  7;}  
     //  ListElement { text:"7"; note:  8;}  
      ListElement { text:"7+5"; note:  9;}  
      ListElement { text:"7+5-9"; note:  10;}  
      ListElement { text:"7-10"; note:  11;}  
      ListElement { text:"7-11"; note:  12;}  
      ListElement { text:"7-13"; note:  13;}  
      ListElement { text:"7-5"; note:  14;}  
      ListElement { text:"7-9"; note:  15;}  
      ListElement { text:"7sus2"; note:  16;}  
      ListElement { text:"7sus4"; note:  17;}  
      ListElement { text:"9"; note:  18;}  
      ListElement { text:"9+5"; note:  19;}  
      ListElement { text:"9sus4"; note:  20;}  
     // ListElement { text:"M"; note:  21;}  
      ListElement { text:"M7"; note:  22;}  
     //  ListElement { text:"a"; note:  23;}  
      ListElement { text:"add11"; note:  24;}  
      ListElement { text:"add13"; note:  25;}  
      ListElement { text:"add2"; note:  26;}  
      ListElement { text:"add4"; note:  27;}  
      ListElement { text:"add9"; note:  28;}  
     //ListElement { text:"dim"; note:  30;}  
     //  ListElement { text:"dim7"; note:  31;}  
      ListElement { text:"dom7"; note:  34;}  
      ListElement { text:"halfdim"; note:  35;}  
     //  ListElement { text:"halfdiminished"; note:  36;}  
      ListElement { text:"i"; note:  37;}  
     //  ListElement { text:"i7"; note:  38;}  
     //ListElement { text:"m"; note:  39;}  
      ListElement { text:"m+5"; note:  40;}  
      ListElement { text:"m11"; note:  41;}  
      ListElement { text:"m11+"; note:  42;}  
      ListElement { text:"m13"; note:  43;}  
      ListElement { text:"m6"; note:  44;}  
      ListElement { text:"m6*9"; note:  45;}  
     //  ListElement { text:"m7"; note:  46;}  
      ListElement { text:"m7+5"; note:  47;}  
      ListElement { text:"m7+5-9"; note:  48;}  
      ListElement { text:"m7+9"; note:  49;}  
     //  ListElement { text:"m7-5"; note:  50;}  
     //  ListElement { text:"m7-9"; note:  51;}  
      ListElement { text:"m7b5"; note:  52;}  
      ListElement { text:"m9"; note:  53;}  
      ListElement { text:"m9+5"; note:  54;}  
      ListElement { text:"madd11"; note:  55;}  
      ListElement { text:"madd13"; note:  56;}  
      ListElement { text:"madd2"; note:  57;}  
      ListElement { text:"madd4"; note:  58;}  
      ListElement { text:"madd9"; note:  59;}  
     // ListElement { text:"maj"; note:  60;}  
      ListElement { text:"maj11"; note:  61;}  
      ListElement { text:"maj9"; note:  62;}  
     //ListElement { text:"min"; note:  65;}  
      ListElement { text:"sus2"; note:  68;}  
      ListElement { text:"sus4"; note:  69;} 
     }//end model
     currentIndex: 0
     style: ComboBoxStyle {
      font.family: 'MScore Text'
      font.pointSize: 12
     }//end style
    }// end combobox
//////////////
    Label {
     text: "Pitch"
    }//end label

    ComboBox {
     id: pivotNote
     Layout.fillWidth:	true
     //width:100
     model: ListModel {
      id: pivotNoteList
      ListElement { text: "C";  note: 0;  }
      ListElement { text: "C♯"; note: 1;  }
      ListElement { text: "D";  note: 2;  }
      ListElement { text: "E♭"; note: 3;  }
      ListElement { text: "E";  note: 4;  }
      ListElement { text: "F";  note: 5;  }
      ListElement { text: "F♯"; note: 6;  }
      ListElement { text: "G";  note: 7;  }
      ListElement { text: "G♯"; note: 8;  }
      ListElement { text: "A";  note: 9;  }
      ListElement { text: "B♭"; note: 10; }
      ListElement { text: "B";  note: 11; }
     }//end listmodel
     currentIndex: 0
     style: ComboBoxStyle {
      font.family: 'MScore Text'
      font.pointSize: 12
     }//end style
    }// end combobox
//////////////
    Label {
     text: "Octave"
    }//end label

    ComboBox {
     id: octave
     Layout.fillWidth:	true
     model: ListModel {
      id: octaveList
      ListElement { text: "1";  note: 0;  }
      ListElement { text: "2"; note: 1;  }
      ListElement { text: "3";  note: 2;  }
      ListElement { text: "4";  note: 3;  }
      ListElement { text: "5";  note: 4;  }
      ListElement { text: "6"; note: 5;  }
      ListElement { text: "7";  note: 6;  }
      ListElement { text: "8"; note: 7;  }
      ListElement { text: "9"; note: 8;  }
      ListElement { text: "10"; note: 9;  }
     }//end listmode
     currentIndex: 3
     style: ComboBoxStyle {
      font.family: 'MScore Text'
      font.pointSize: 14
     }//end style
    }// end combobox
/////////////////////
    Label {
     text: "Note time"
    }//end label

    ComboBox {
     id: noteType
     Layout.fillWidth:	true
     model: ListModel {
      id: noteTypeList
      ListElement { text: "1/32";  note: 0;  }
      ListElement { text: "1/16"; note: 1;  }
      ListElement { text: "1/8";  note: 2;  }
      ListElement { text: "1/4";  note: 3;  }
      ListElement { text: "1/2";  note: 4;  }
      ListElement { text: "1"; note: 5;  }
     }//end listmode
     currentIndex: 2
     style: ComboBoxStyle {
      font.family: 'MScore Text'
      font.pointSize: 14
     }//end style
    }// end combobox
/////////////////////
    Label {
     text: "Chord Inversion"
    }//end label

    ComboBox {
     id: cInversion
     Layout.fillWidth:	true
     model: ListModel {
      id: cInvertList
      ListElement { text: "-7";  note: -7;  }
      ListElement { text: "-6"; note: -6;  }
      ListElement { text: "-5";  note: -5;  }
      ListElement { text: "-4";  note: -4;  }
      ListElement { text: "-3";  note: -3;  }
      ListElement { text: "-2"; note: -2;  }
      ListElement { text: "-1";  note: -1;  }
      ListElement { text: "0";  note: 0;  }
      ListElement { text: "1";  note: 1;  }
      ListElement { text: "2"; note: 2;  }
      ListElement { text: "3";  note: 3;  }
      ListElement { text: "4";  note: 4;  }
      ListElement { text: "5";  note: 5;  }
      ListElement { text: "6"; note: 6;  }
      ListElement { text: "7";  note: 7;  }

     }//end listmode
     currentIndex: 7
     style: ComboBoxStyle {
      font.family: 'MScore Text'
      font.pointSize: 14
     }//end style
    }// end combobox
//////////
    Button {
     id: applyButton
     text: qsTranslate("PrefsDialogBase", "Enter")
     onClicked: {
      apply();
     }//end onclicked
    }//end apply button
/////////////////////
    Button {
     id: skipButton
     text: qsTranslate("PrefsDialogBase", "Skip")
     onClicked: {
      if(cscore)cscore.startCmd();
      if(cursor)cursor.next();
      if(cscore) cscore.endCmd();
     }//end on clicked
    }//end cancel button
 ///
   Button {
     id: cancelButton
     text: qsTranslate("PrefsDialogBase", "Exit")
     onClicked: {
      if(cscore) cscore.endCmd();
      myWindow.close();
      Qt.quit();
     }//end on clicked
    }//end cancel button
///
   Button {
     id: resetButton
     text: qsTranslate("PrefsDialogBase", "Reset")
     onClicked: {
      rflag=false; // resets apply function to accept a new selection og music
     }//end on clicked
    }//end reset button

   }//end GridLayout
  }//end rectangle
 }//end myWindow
/////
 MessageDialog {
  id: errorDialog
  title: "Error"
  text: ""
  onAccepted: {
   Qt.quit()
  }//end onaccepted
  visible: false
 }//end message dialog
}//end Musescore

