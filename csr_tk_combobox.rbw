#!/usr/bin/env ruby 
#Encode: utf-8
=begin
This small script will help me to create CERTIFICATE SIGNING REQUESTS with less clicks. 

Copyright (C) 2015 Timo Schlappinger

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end

require 'tk'
require 'tkextlib/tile'


root = TkRoot.new {title "Create CSR for SSL"}
content = Tk::Tile::Frame.new(root) {padding "3 3 8 8"}.grid( :sticky => 'nsew')
TkGrid.columnconfigure root, 0, :weight => 1; TkGrid.rowconfigure root, 0, :weight => 1

#Variablen
$domain = TkVariable.new; $dir = TkVariable.new; $key = TkVariable.new; $stdKkey = TkVariable.new;
keysize=[4096,2048,1024]

begin
    about = TkPhotoImage.new(:file => "about.gif")
rescue
    puts 'Could not find about.gif!'
end

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
Tk::Tile::Button.new(content) {text 'About'; command {about_us}; image about}.grid( :column => 3, :row => 1, :sticky => 'w')

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
        bits = $key.get
        $btnCSR.state('enabled')
		if $os == 'windows'
			system ("cmd.exe /c \"openssl\" genrsa -out #{$dir}\\#{$domain}.key #{bits}")
	    elsif $os == 'unix'
			system ("xterm -e openssl genrsa -out #{$dir}//#{$domain}.key #{bits}")
		end
     end 
    rescue
         $domain== ''
	     Tk::messageBox :message => "Could not be created!", :title => 'KEY FILE GENERATION'
    end
end

def createCSR
     begin
	    if $os == 'windows' 
           system ("cmd.exe /c \"openssl\" req -new -key #{$dir}\\#{$domain}.key -out #{$dir}\\#{$domain}.csr -sha512")
        elsif $os == 'unix'
		   system ("xterm -e openssl req -new -key #{$dir}//#{$domain}.key -out #{$dir}//#{$domain}.csr -sha512")
		end
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

def platform
  $RUBY_PLATFORM ||=
    case RUBY_PLATFORM.downcase
      when /linux|bsd|solaris|hpux|powerpc-darwin/
        then $os= 'unix'
      when /mswin32|mingw32|bccwin32/
        then $os='windows'
      else
        :other
    end
end

def about_us
    t = TkToplevel.new(root)
	t.title 'License Information'
	content = Tk::Tile::Frame.new(t) {padding "3 3 8 8"}.grid( :sticky => 'nsew')
	Tk::Tile::Label.new(content) {text 'Copyright (C) 2015 Timo Schlappinger'}.grid( :column => 1, :row => 1, :sticky => 'we', :columnspan => '2');
	txt = TkText.new(content) {width  '80'; height '20'}.grid( :column => 2, :row => 2, :sticky => 'e')
	begin
	    infile = File.open 'license.txt','r'
	    while line = infile.gets
	       txt.insert 'end', line
	    end
		infile.close
	end
	Tk::Tile::Label.new(content) {text 'Email: tim2611@gmail.com '}.grid( :column => 1, :row => 4, :sticky => 'we', :columnspan => '2');
	Tk::Tile::Button.new(content) {text 'Ok'; command {t.destroy}}.grid( :column => 2, :row => 4, :sticky => 'e')
end

$os = platform

Tk.mainloop
