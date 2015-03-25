#Encode: utf-8
require 'tk'
require 'tkextlib/tile'

root = TkRoot.new {title "Create CSR for SSL"}
content = Tk::Tile::Frame.new(root) {padding "3 3 8 8"}.grid( :sticky => 'nsew')
TkGrid.columnconfigure root, 0, :weight => 1; TkGrid.rowconfigure root, 0, :weight => 1

#Variablen
$domain = TkVariable.new; $dir = TkVariable.new; $key = TkVariable.new; $stdKkey = TkVariable.new;
keysize=[4096,2048,1024]
#stdKey='4096'

#Gui Elemente
#Text
$edtDomain = Tk::Tile::Entry.new(content) {width 7; textvariable $domain}.grid( :column => 2, :row => 2, :sticky => 'we')
$edtDomain.state('disabled')
#Label
Tk::Tile::Label.new(content) {text 'Directory:'}.grid( :column => 1, :row => 1, :sticky => 'w');
Tk::Tile::Label.new(content) {text 'Domainname:'}.grid( :column => 1, :row => 2, :sticky => 'e');
Tk::Tile::Label.new(content) {text 'Key:'}.grid( :column => 1, :row => 3, :sticky => 'w');
#Combobox
$key = Tk::Tile::Combobox.new(content) {values keysize; textvariable $stdKey}.grid( :column => 2, :row => 3, :sticky => 'w')
$key.set('4096')
$key.state('disabled')
#Buttons
$btnKey = Tk::Tile::Button.new(content) {text 'create Key'; command {createKey}}.grid( :column => 1, :row => 4, :sticky => 'w')
$btnKey.state('disabled')
$btnCSR = Tk::Tile::Button.new(content) {text 'create CSR'; command {createCSR}; state 'disabled'}.grid( :column => 2, :row => 4, :sticky => 'w')
$btnDir = Tk::Tile::Button.new(content) {text 'Dir'; command {setDir}}.grid( :column => 2, :row => 1, :sticky => 'w')
Tk::Tile::Button.new(content) {text 'Exit'; command {exit}}.grid( :column => 3, :row => 4, :sticky => 'e')

TkWinfo.children(content).each {|w| TkGrid.configure w, :padx => 5, :pady => 5}
#Set start focus to Dir button
$btnDir.focus
root.bind("Return") {calculate}

#Funktionen
def exit
    root.destroy
end

def createKey
    begin
         if $domain == ''
         Tk::messageBox :message => 'Please enter domain...', :title => "oh no..."
         $edtDomain.focus
     elsif $dir == ''
        Tk::messageBox :message => 'Please set directory...', :title => "oh no..."
        $btnDir.focus
     else
        mykey = $key.get
        $btnCSR.state('enabled')
        system ("cmd.exe /c \"C:\\Program Files\\openssl\\openssl.exe\" genrsa -out #{$dir}\\#{$domain}.key #{mykey}") 
     end
    rescue
         $domain== ''
	     Tk::messageBox :message => "Could not be created!", :title => 'KEY FILE GENERATION'
    end
end

def createCSR
     begin
         system ("cmd.exe /c \"C:\\Program Files\\openssl\\openssl.exe\" req -new -key #{$dir}\\#{$domain}.key -out #{$dir}\\#{$domain}.csr -sha512")
         Tk::messageBox :message => "Finished! You will find it in #{$dir}\/", :title => 'CERTIFICATE REQUEST'
     rescue
         Tk::messageBox :message => "Could not be finished!", :title => 'CERTIFICATE REQUEST'
    end
end

def setDir
     begin
         $dir = Tk::chooseDirectory
         $edtDomain.state('enabled')
         $key.state('enabled')
         $btnKey.state('enabled')
         $edtDomain.focus
     rescue
         Tk::messageBox :message => "Could not set directory!", :title => 'CHOOSE DIRECTORY'
     end
end

Tk.mainloop
