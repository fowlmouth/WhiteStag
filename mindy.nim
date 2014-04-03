import WhiteStagEditor/window
import WhiteStagEditor/sdlengine
import WhiteStagEditor/view
import WhiteStagEditor/pixel
import WhiteStagEditor/option
import WhiteStagEditor/desktop
import WhiteStagEditor/selectbox
import WhiteStagEditor/event
import WhiteStagEditor/scrollableViewWrapper
import WhiteStagEditor/scrollbar
import WhiteStagEditor/progressbar
import WhiteStagEditor/button
import WhiteStagEditor/radiogroup
import WhiteStagEditor/checkboxgroup
import WhiteStagEditor/textfield
import WhiteStagEditor/tree
import WhiteStagEditor/stringtree
import WhiteStagEditor/dialog
import WhiteStagEditor/list
import WhiteStagEditor/textarea
import WhiteStagEditor/panel

type
  TMindy* = object of TApplication
  TQuestion = object
    problemStatement: string

const
  chooseTypeAndOrContainsCmd = TCmd("chooseTypeAndOrContainsCmd")
  chooseTypeControlledSkippingCmd = TCmd("chooseTypeControlledSkippingCmd")
  chooseTypeRandomSkippingCmd = TCmd("chooseTypeRandomSkippingCmd")
  chooseTypeTrueFalseCmd = TCmd("chooseTypeTrueFalseCmd")
  chooseTypeMirrorCmd = TCmd("chooseTypeMirrorCmd")

  selectQuestionTypeCmd = TCmd("selectQuestionTypeCmd")
  W = 80
  H = 40

var usersMenu = createStringSelectBox("Balázs", false)
discard usersMenu.addItem("Bettina", cmdOk)
discard usersMenu.addItem("Béla", cmdOk)
discard usersMenu.addItem("Károly", cmdOk)
discard usersMenu.addItem("Józsi", cmdOk)

var questionEditorWindow = createWindow(W - 5, H - 5, "Adding new question")
questionEditorWindow.closeable = false
questionEditorWindow.resizable = true
questionEditorWindow.growMode = {}

var questionTypeSelectBox = createStringSelectBox("Type")
discard questionTypeSelectBox.addItem("And, Or, Contains", cmdOk)
discard questionTypeSelectBox.addItem("Controlled skipping", cmdOk)
discard questionTypeSelectBox.addItem("Random skipping", cmdOk)
discard questionTypeSelectBox.addItem("True-false", cmdOk)
discard questionTypeSelectBox.addItem("Mirror", cmdOk)

var typeButton = createButton("And, Or, Contains", selectQuestionTypeCmd)
questionEditorWindow.addView(typeButton, 3, 1)


proc fillAndOrContainsPanel(panel: PPanel, question: ref TQuestion) =
  let radioGrp = createRadioGroupWithoutFrame()
  radioGrp.addItem("And")
  radioGrp.addItem("Or")
  radioGrp.addItem("Contains")
  panel.addView(radioGrp, panel.w - 2 - radioGrp.w, 0)


  let problemStatementTextArea = createTextArea(panel.w - 2 - radioGrp.w - 2, 10)
  problemStatementTextArea.font = some(engine.loadFont(14))
  panel.addView(problemStatementTextArea, 0, 0)
  

  var inputFieldsPanel = createPanel(30, 5)
  let inputW = panel.w div 2 - 4
  var input0 = createTextArea(inputW, 1)
  var input1 = createTextArea(inputW, 1)
  var input2 = createTextArea(inputW, 1)
  var input3 = createTextArea(inputW, 1)
  var input4 = createTextArea(inputW, 1)
  var input5 = createTextArea(inputW, 1)
  inputFieldsPanel.addView(input0, 0, 0)
  inputFieldsPanel.addView(input1, 0, 2)
  inputFieldsPanel.addView(input2, 0, 4)

  inputFieldsPanel.addView(input3, 4 + inputW, 0)
  inputFieldsPanel.addView(input4, 4 + inputW, 2)
  inputFieldsPanel.addView(input5, 4 + inputW, 4)

  panel.addView(inputFieldsPanel, 2, 15)


var menuWindow = createWindow(35, 10, "Projects")
menuWindow.closeable = false
menuWindow.resizable = false
menuWindow.growMode = {}

var application = new(TMindy)

var deskt = createDesktop(application, 80, 40, 14)
deskt.addViewAtCenter(menuWindow)

var switchUserButton = createButton("Felhasználó váltása", TCmd("switchUserButton"))
var startButton = createButton("Kezdés", TCmd("Start"))
var newButton = createButton("Új hozzáadása", TCmd("addNewQuestion"))
var editButton = createButton("Szerkesztés", TCmd("Start"))
var exitButton = createButton("Kilépés", cmdCancel)
menuWindow.addViewAtCenter(switchUserButton, -2)
menuWindow.addViewAtCenter(startButton, -1)
menuWindow.addViewAtCenter(newButton, 0)
menuWindow.addViewAtCenter(editButton, 1)
menuWindow.addViewAtCenter(exitButton, 2)

discard deskt.execute()

method handleEvent(self: ref TMindy, event: PEvent) = 
  case event.kind:
  of TEventKind.eventCommand:
    if event.cmd == TCmd("switchUserButton"):
      event.setProcessed()
      let result = menuWindow.executeView(usersMenu, switchUserButton.x + switchUserButton.w div 2, switchUserButton.y)
      if result.cmd == cmdCancel:
        return
      let resultNameString = cast[string](result.data)
      menuWindow.title = resultNameString
      menuWindow.modified()
    elif event.cmd == TCmd("addNewQuestion"):
      deskt.addViewAtCenter(questionEditorWindow)
      #let result = deskt.executeView(questionEditorWindow, 0, 0)
    elif event.cmd == selectQuestionTypeCmd:
      let questionType = cast[string](questionEditorWindow.executeView(questionTypeSelectBox, typeButton.x, typeButton.y).data)
      typeButton.label = questionType
      let andOrContainsPanel = createPanel(questionEditorWindow.w-2, questionEditorWindow.h - 3 - 5)
      fillAndOrContainsPanel(andOrContainsPanel, nil)
      questionEditorWindow.addView(andOrContainsPanel, 1, 3)
  else:
    discard