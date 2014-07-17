/*
    This program is part of the Niarbyl software, which is a free 
    software: you can redistribute it and/or modify it under the 
    terms of the GNU General Public License as published by the 
    Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    
    
    USES :
    ======
    
    This is the interface that a client may use to call the niarbyl machine.
    The client itself may be a user or any other program or any entity, 
    who has to access the niarbyl machine via the OS.
*/


import tango.io.Stdout;
// phobos
import std.getopt , std.stdio, std.string , std.math , std.conv,
std.range, std.algorithm, std.array, std.stream, std.regex, core.stdc.stdio, core.stdc.stdlib;


// niarbyl
import niarbylmachine;


// this interface is NOT written as a module


// globals
niarbylmachine.markupReader Reader;

string inputfl, grammarfl, searchtrgt;


void main(string[] args)
{

    
    getopt(args,
    "inpt", &inputfl,
    "grmr", &grammarfl,
    "trgt", &searchtrgt
    );
    
    Reader = new niarbylmachine.markupReader();
    
    // initiate
    Reader.initiate(inputfl, grammarfl);
    
    
    // load the grammar[s];
    Reader.loadGrammar();
    
    
    
    // Set the grammar applicabilities:
    Reader.setGrammar();
    
    // finally, find the target being sought for
    
    // extract the dara, and save in string "raw"

    for(int ii = 0; ii < Reader.Grammars.count(); ii++)
    {
	Stdout(ii).nl();
	Stdout(Reader.Grammars[ii].has).nl();
	Stdout(Reader.Grammars[ii].lacks).nl();
	
    }
    
    
    
    // Reader ready.
    
    Reader.readTarget(searchtrgt, "");
    
    
    
    
}