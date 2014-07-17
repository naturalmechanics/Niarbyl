/*
 *   This program is part of the Niarbyl software, which is a free 
 *   software: you can redistribute it and/or modify it under the 
 *   terms of the GNU General Public License as published by the 
 *   Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 * 
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 * 
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 *   
 *   
 *   USES :
 *   ======
 *   
 *   This is the niarbyl machine used to read various kind of data.
 */









module niarbylmachine;								// module declared



/** imports **/

// tango
import 	tango.io.Stdout;							

// phobos
import 	std.getopt, std.stdio, std.string, 
std.math, std.conv, std.range, 
std.algorithm, std.array, std.stream, 
std.regex;

// Further add-on -s
import array_manip, file_io, string_libs;









/** globals **/

// structs

// ---------- needed by the markup reader

struct grammar {		// grammar
  
  string[] enclosers;		// enclosers
  string separator;		// separator between key and value
  string entry_sep;		// separator between entries
  string content_key;		// the key that lists the contents
  string id_key;		// the key that contains the ID as a value
  
  string[] trg_keyname_h;	// check targets, for has command
  string[] trg_keyname_l;	// check targets, for lacks command
  string[] has;		// check whether targets contain the elements of this array
  string[] lacks;		// check whether targets lack the elements of this array
  
}


struct result {		// result 
  
  string[] raw; 	// the raw data as picked up by grammar
  string res;		// the formatted output
  
}







// ----------- needed by the heirarchical reader

struct tree {						// retrun a tree structure
  
}


struct knot(T, U) {					// knot is same as node, but the name node is already taken
							// multiple knots make up an arc
  T prec;						// precedessor
  short type;						// which of the following options
  T ID;							// either an integer ID for the knot
  U cnt;						// content of the knot
  arc!(T, U) * arcp;					// or a point to another arc
  T succ;						// successor	
}



struct arc(T, U) {				// the arc, that is supposed to be made by knots
  
  T initmark;					// at which identifier does it start?
  knot!(T, U)[] knots;				// ...
  T endmark;					// ...
  short cnttp;
}


struct fractalSet_symbolic_1Dbase(T, U) {		// return a fractal set, constructed upon surnumber tuples
							// a single set for a sinlge readout contains the whole hierarchy.
  string raw;						// the raw readout.
  arc!(T, U) [] arcs;					// and finally, the arc that make the set.
  
}



// ----------- needed by the command parser

struct parseRes {
  
  short type;
  string res;
  parseRes[] compoundRes;
  
}












// classes 
class markupReader {
  
  string inputFl;			// input file
  string grmrFl;			// grammar file
  string searchTrgt;			// search target in the file
  
  
  grammar[] Grammars;			// list of grammars to be used
  result[] Results;			// list of results
  int[][] GrammarBoundaries;
  
  this()
  {
  }
  
  ~this()
  {
  }
  
  
  //------------------ methods
  
  void initiate(string inFl, string grFl)	// Specifically a function and not the default constructor
  {
    inputFl = inFl;
    grmrFl = grFl;
  }
  
  
  void loadGrammar()				// load all the grammars from the grammarfile
  {
    auto f_ = std.stdio.File(grmrFl, "r");   	// open the grammarfile
    short i_ = 1;				// a counter to keep track of the lines
    string ln;					// string to hold one line read from the file at a time
    grammar * Grammar = new grammar;		// a grammar that we will need
    
    while(!f_.eof())				// while can read file
    {
      while(i_ <= 9 && !f_.eof())		// while all 9 lines are not read yet
      {
	
	switch(i_)				// based on which line we are reading
	{
	  case 1:
	    // read the enclosing characters
	    ln = f_.readln().chomp();
	    Grammar.enclosers = ln.split(" ");
	    break;
	    
	  case 2:
	    // read the string differentiating the
	    // key and the value;
	    ln = f_.readln().chomp();
	    Grammar.separator = ln;
	    break;
	    
	  case 3:
	    // read the entry separator
	    ln = f_.readln().chomp();
	    Grammar.entry_sep = ln;
	    break;
	    
	    // if the next ones are not specified, 
	    // we have an EOF
	    // the inner while loop wont reach here
	    
	  case 4:
	    // read the content key
	    ln = f_.readln().chomp();
	    Grammar.content_key = ln;
	    break;
	    
	  case 5:
	    // read the ID key
	    ln = f_.readln().chomp();
	    Grammar.id_key = ln;
	    break;
	    
	  case 6:
	    // read the trg_keyname
	    ln = f_.readln().chomp();
	    if (ln != "")
	      Grammar.trg_keyname_h = ln.split(";");
	    else
	      Grammar.trg_keyname_h = [];
	    break;
	    
	  case 7:
	    // read the has or lacks command, 
	    // and edit it as necessary
	    ln = f_.readln().chomp();
	    
	    if(ln != "")
	    {
	      if(ln[0 .. 4] == "has:")
		Grammar.has = ln[4 .. $].split(";"); 
	      else if(ln[0 .. 6] == "lacks:")
		Grammar.lacks = ln[6 .. $].split(";");
	    }
	    break;
	       
	  case 8:
	    // read the trg_keyname
	    ln = f_.readln().chomp();
	    if (ln != "")
	      Grammar.trg_keyname_l = ln.split(";");
	    else
	      Grammar.trg_keyname_l = [];
	    break;
	    
	  case 9:
	    // read the has or lacks command, 
	    // and edit it as necessary
	    ln = f_.readln().chomp();
	    
	    if(ln != ""){
	      if(ln[0 .. 4] == "has:")
		Grammar.has = ln[4 .. $].split(";"); 
	      else if(ln[0 .. 6] == "lacks:")
		Grammar.lacks = ln[6 .. $].split(";");
	    }
	    break;
	    
	  default:
	    break;
	    
	}
	
	i_++;
	
	
      }
      Grammars.assumeSafeAppend();		// take care of things
      // TODO : Look up why assumesafeappend is necessary
      Grammars ~= *Grammar;			// append grammar Grammar
     
      i_ = 0;					// reset i
      Grammar = new grammar;			// reset Grammar
    }
    
    f_.close();    
    // this will automatically call expandGrammar ; 
    
    expandGrammar();
    
  }
  
  
  void expandGrammar()				// expand the grammars based on there has or lack options, 
						// each has or lack target should have a SINGLE value
  {
    
    grammar[] G;
    grammar * g;
    string[] hs;
    string[] ls;
    int andCnt, orCnt; 
    string[][] hh;
    string[][] hk;
    string[][] ll;
    string[][] lk;
    
    G = [];	// no grammar in the list of modified, expanded grammars
    
    foreach(grammar Grm; Grammars)
    {
      
      if(Grm.has.count() != 0) // we have has keywords
      {
	
	hh = []; // empty list of all has
	foreach(h; Grm.has)
	{
	  hs = h.split(",");
	  hh ~= hs;
	}
	
	// now we have the jagged array hh
	hk = flatten_array(hh);
	
	foreach(hhk; hk)
	{
	  // set the grammar
	  g = new grammar;
	  g.enclosers = Grm.enclosers;
	  
	  g.separator = Grm.separator;
	  g.entry_sep = Grm.entry_sep;
	  g.content_key = Grm.content_key;
	  g.id_key = Grm.id_key;
	  g.trg_keyname_h = Grm.trg_keyname_h;
	  g.trg_keyname_l = Grm.trg_keyname_l;
	  g.has = hhk;
	  g.lacks = Grm.lacks;
	  G ~= *g;
	}
	
	
      }
      else
      {
	  G ~= Grm;
      }
      
      
    }
    
    Grammars = G;

    G = []; // reset again, do the same with lacks
    
    foreach(grammar Grm; Grammars)
    {
      if(Grm.lacks.count() != 0)
      {
	
	ll = []; // empty
	foreach(l; Grm.lacks)
	{
	  ls = l.split(",");
	  ll ~= ls;
	}
	
	// now we have the jagged array hh
	lk = flatten_array(ll);
	
	foreach(llk; lk)
	{
	  g = new grammar;
	  g.enclosers = Grm.enclosers;
	  
	  g.separator = Grm.separator;
	  g.entry_sep = Grm.entry_sep;
	  g.content_key = Grm.content_key;
	  g.id_key = Grm.id_key;
	  g.trg_keyname_l = Grm.trg_keyname_l;
	  g.trg_keyname_h = Grm.trg_keyname_h;
	  g.lacks = llk;
	  g.has = Grm.has;
	  G ~= *g;
	}
      }
      else
      {
	G ~= Grm;
      }
      
      
    }
    
    Grammars = G;
    
  }
  
  
  
  void setGrammar()
  {
    
    int[][] boundaries = extractBoundaries();
    
    int bbi = 0;
    for(bbi = 0; bbi <Grammars.count(); bbi ++)
    {
      boundaries[bbi][1] = boundaries[bbi][1] + to!int(Grammars[bbi].enclosers[1].count()) - 1;
    }
    
    // foreach grammar;
    // pick list of boundaries - each grammar can have multiple boundaries
    // foreach boundary
    // if the grammar does not apply
    // kill that boundary
    
    // then we have an ordered list of grammars
    // and a corresponding ordered list of boundaries
    
    // then in order to find target
    // one can scan the file, picking up the correct 
    // grammars between boundaries
    
    grammar G, Grm;
    grammar[] G_;
    int[] b;
    string rdout;
    string chkTrgt;
    auto f = new std.stream.File(inputFl);
    
    int i,j,k, rj;
    
    int tc, ti;
    
    ulong chkrs;
    string hj;
    
    
    // Stdout("*****").nl();
    
    
    for(i = 0; i < Grammars.count(); i++)
    {
      
      
      b = boundaries[i];
      rdout = "";
      
      
      // form the check target
      
      
      
      tc = to!int(Grammars[i].trg_keyname_h.count());
      
      
      rj = j; // intial remove target
      
      for(j = 0; j < b.count() ; j = j+2)
      {
	
	chkrs = 1;    
	
	for(ti = 0; ti < tc; ti ++)
	{
	  // make the chk trg
	  chkTrgt = Grammars[i].trg_keyname_h[ti] ~ Grammars[i].separator ~ Grammars[i].has[ti]; // each key has a single value. multiple values have been splitted
	  
	  
	  
	  // extract from file 
	  f.seek(b[j], SeekPos.Set) ;
	  k = j;
	  while(k <= b[j+1] && !f.eof())
	  {
	    rdout = rdout ~ f.getc();
	    k++;
	  }
	  
	  // regexMatchCnt      
	  
	  chkrs = chkrs * regexMatchCnt(rdout, chkTrgt);
	  
	  
	  
	  
	  
	  
	  
	}
	
	
	if (chkrs == 0) // check failed
	{
	  boundaries[i] = remove(boundaries[i], rj);
	  boundaries[i] = remove(boundaries[i], rj+1);
	}
	else // perhaps you will have to kill the next j
	{
	  rj = j;
	}
	
	
      }
      
    }
    
    f.close();
    
    GrammarBoundaries = boundaries;
    
    
  }
  
  
  
  void readTarget(string target, string Format)
  {
    
    // figure out, if any of the grammars can identify the target
    // if Not, then break
    // if at this point then  parse the readout to a the required output format
    
    
    string ID, key;
    string IDSep, keySep;
    
    
    string readout;
    int i,j,k;
    int p = 0, q;
    char ch;
    ulong regxcount;
    string[] regexMatches;
    
    switch(Format)
    {
	case "raw":
	  // find ID from target
	  ID = target[0 .. target.count() - find(target,'.').count()];
	  key = target[ target.count() - find(target,'.').count()+1 .. $];
	  auto f_ = new std.stream.File(inputFl);
	  
	  for (j = 0; j < Grammars.count(); j++)
	  {
	    // construct ID + seperator
	      IDSep = Grammars[j].id_key ~ Grammars[j].separator ~ ID;
	      
	    // construct key + seperator
	    
	      keySep = key ~ Grammars[j].separator;
	      
	      for(i = 0; i < GrammarBoundaries[j].count(); i++){
		  f_.seek(GrammarBoundaries[j][i], SeekPos.Set);
		  k = GrammarBoundaries[j][i];
		  
		  // get balanced readout
		  
		  readout = "";
		  // the first one is ALWAYS an opening brace
		  q = GrammarBoundaries[j][i];
		  while(true)
		  {
		    ch = f_.getc();
		    readout ~= ch;
		    
		    p = to!int(readout.count(Grammars[j].enclosers[0])  - readout.count(Grammars[j].enclosers[1]));
		    
		    if(p == 0)
		      break;
		      
		      q ++;
		  }
		  
		  // now figure out which boundary location you are in;
		  for(int m = 0; m < GrammarBoundaries[j].count(); m++)
		  {
		      if (q >= GrammarBoundaries[j][m]) // so we have touched the start of encloser, and copied also the further chars of the enclosers
		      {
			i = m; // start with next i;
		      }
		  }
		  
		  
		  
		  
		  regxcount = regexMatchCnt(readout, IDSep);
		  if(regxcount != 0)
		  {
		      // the ID matches
		      regexMatches = regexGetMatch(readout, keySep);
		      
		      
		      if (regexMatches.count() != 0) // we found something, the first one suffices
		      {
			  result* res;
			  res = new result;
			  res.raw ~= readout;
			  
			  res.res = find(readout, regexMatches[0])[regexMatches[0].count() - 1 .. $];
			  res.res = res.res[0 .. res.res.count() - find(res.res, Grammars[j].entry_sep).count()];
			  
			  
			  Results ~= *res;
			 
		      }
		  }
		  
		  
	      }
	      
	  }
	  f_.close();
	  
	  break;
	case "parse":
	  break;
	default:
	break;
    }
    
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  int[] removeUpto(int[] trgar, int lm)
  {
    
    
    int[] k = find(trgar, lm);
    if(k == [])
      return [];
    else
      return k[1 .. $];
    
  }
  
  
  
  
  int[][] extractBoundaries()
  {
    int[] e1;
    int[] e2;
    int[] ee1;
    int[] ee2;
    int[] e;
    int[] e_trk;
    int[][] te;
    int[][] te_trk;
    int[][] boundaries;
    
    
    // first get the boundaries
    
    foreach(grammar Grm; Grammars)
    {
      
      // find where the enclosers are
      e = [];
      e_trk = [];
      
      //locate opening enclosers
      e1 = getLocations_inFile(Grm.enclosers[0], inputFl);
      
      //locate closing enclosers
      e2 = getLocations_inFile(Grm.enclosers[1], inputFl) ;
      
      
      
      
      // arrange it
      ee1 = e1;
      ee2 = e2;
      
      
      
      
      while(1)
      {
	// if we have 0, then break;
	if (ee1.count() == 0 && ee2.count() == 0)
	{
	  break;
	}
	
	
	if (ee1.count() == 0)
	{
	  // if we dont have the openning any more
	  e ~= ee2[0];	// our encloser is just the closing encloser, copy the location
	  e_trk ~= 2;	// and mention that we are copying the second encloser
	  ee2 = ee2[1 .. $]; //pop
	  continue;
	}
	
	if (ee2.count() == 0)
	{
	  // same as above, but just the other indices
	  e ~= ee1[0];
	  e_trk ~= 1;
	  ee1 = ee1[1 .. $];
	  continue;
	}
	
	
	// select the one of ee1 and ee2, which ever appears first in the stream
	
	if(ee1[0] < ee2[0])
	{
	  e ~= ee1[0];
	  e_trk ~= 1;
	  ee1 = ee1[1 .. $];
	}
	else if(ee1[0] > ee2[0])
	{
	  e ~= ee2[0];
	  e_trk ~= 2;
	  ee2 = ee2[1 .. $];
	}
	
	
	
	
      }
      
      te ~= e;
      te_trk ~= e_trk; 	// saved both e and e_trk in the bigger array, each i-th element of te is an array, and 
      // are the locations of enclosers of the i-th grammar.
      
      
      
    }     
    
    
    // TESTED :so far so good
    
    // Now use the comparators, 
    // to find supersets
    
    int cntr;
    int cntr2;
    
    
    string[] subs, sups;
    
    grammar * subg,  supg;
    
    int ie1, je1;
    int ie2, je2;
    int l = -1;
    // string subs, sups;
    
    int jk, kk;
    
    bool skip = false;
    
    for (cntr = 0; cntr < Grammars.count() ; cntr++)
    {
      
      // find the absolute supper grammar
      subg = new grammar;
      subg = &Grammars[cntr];
      
      subs = subg.enclosers;
      
      for(cntr2 = 0; cntr2 < Grammars.count() ; cntr2++)
      {   
	if(cntr == cntr2)
	{ skip = true; continue;}
	if(cntr != cntr2)
	{
	  supg = new grammar;
	  supg = &Grammars[cntr2];
	  
	  sups = supg.enclosers;
	  
	  if(canFind(sups[0], subs[0]) && canFind(sups[1], subs[1]))
	  {
	    l = cntr2;
	    subs = sups;
	    continue;
	  }
	}
      }
      
      
      // now sups is the maximum super enclosers
      
      // grammars[l] = supg
      // cntr is the current grammar against which we look for supgs.
      
      
      // we assume that it is ballanced
      
//       if(cntr == cntr2-1){
// 	  Stdout(cntr2 <= Grammars.count()-1).nl();
// 	  Stdout(Grammars[cntr].has).nl();
// 	  Stdout(cntr2).nl();
// 	  Stdout(cntr).nl();
// 	  Stdout(Grammars.count()).nl();
//       }
      if (l != -1 )//&& cntr != cntr2-1) // l has been found, and cntr is not the last one, 
	// in the last one, where cntr2 breaks out of the for loop,
	// then cntr is one more
	
      {
	
	
	ie1 = -1;
	ie2 = -1;
	
	
	
	for(kk =0 ; kk < te[l].count(); kk++)
	{
	  for(jk = 0 ; jk < te[cntr].count(); jk++)
	  {
	    if(jk != 0)
	    {
	      if (te[l][kk] <= te[cntr][jk] && te[l][kk] >= te[cntr][jk-1])
	      {  ie1 = jk; break; }
	    }
	    else
	    {
	      if (te[l][kk] <= te[cntr][jk])
	      {  ie1 = jk; break; }
	    }
	  }
	  
	  for(jk = 0 ; jk < te[cntr].count(); jk++)
	  {
	    if(jk != te[cntr].count()-1)
	    {
	      if (te[l][kk+1] >= te[cntr][jk]  && te[l][kk+1]+supg.enclosers[1].count()-1 <= te[cntr][jk+1]){
		ie2 = to!int(te[cntr].count() - find(te[cntr],te[l][kk+1]+supg.enclosers[1].count()-1).count());
		if(ie2 == -1)
		  ie2 = jk; 
		break; }
		
		
		
	    }
	    else
	    {
	      if (te[l][kk+1] >= te[cntr][jk])
	      {  ie2 = jk; break; }
	    }
	    
	  }
	  
	  // 		// now we have the boundary
	  
	  if(ie1 != -1 && ie2 != -1)
	  {
	    if (ie1 == 0 && ie2 == te[cntr].count()-1)
	    { //te[cntr] = []; te_trk[cntr] = [];
	    }
	    else if (ie1 == 0 && ie2 != te[cntr].count()-1)
	    { te[cntr] = te[cntr][ie2+1 .. $]; te_trk[cntr] = te_trk[cntr][ie2+1 .. $];}
	    else if (ie1 != 0 && ie2 == te[cntr].count()-1)
	    { te[cntr] = te[cntr][0 .. ie1-1]; te_trk[cntr] = te_trk[cntr][0 .. ie1-1];}
	    else if (ie1 != 0 && ie2 != te[cntr].count()-1)
	    { te[cntr] = te[cntr][0 .. ie1-1] ~ te[cntr][ie2+1 .. $]; te_trk[cntr] = te_trk[cntr][0 .. ie1-1] ~ te_trk[cntr][ie2+1 .. $];}
	  }
	  kk++ ; 	    
	}
	
      }
      
    }
    
    boundaries = te;
    //Stdout(te).nl();
    return boundaries;
    
  }
  
  
  
  ulong regexMatchCnt(string haystack, string needle)
  {
    auto r = regex(needle, "g");
    auto m = match(haystack, r);
    int i;
    
    foreach(c; m) {
      i++; }
      return i;
  }
  
  string[] regexGetMatch(string haystack, string needle)
  {
    auto r = regex(needle, "g");
    auto m = match(haystack, r);
    string[] res;
    
    foreach(c; m) {
      res ~= c.hit; }
      return res;
  }
  
  
  
  
  
  
}


class hierarchicalReader
{
  
  /* 
   Hierarchical readers are specifically designed to generate a fractal set
   to represent the hierarchical relation between grammars. 
   
   While it is possible to emulate hierarchical structure of data points
   using any markup, the hierarchical reader can exploit a more concise syntax, 
   because it expects a certain hierarchy in the data, thus interpretes, 
   without the aid of a markup, certain tokens of the syntax as certain objects
   related to the hierarchy.
  */
  
  // globally accessible stuff
  string inputFl;
  
  
  // stuff that needs to be set during initialization;
  
  short fractalSet_basedim;			// base dinension of the fractal set. 
						// this is the basic initialization variable
						// all other varibales related to initialization follow this.
						// besides cnttp
  
  string arc_type;				// arc type
  string cnttp;					// content type
  
  // other stuff
  string all_raw;
  fractalSet_symbolic_1Dbase!(string, string[]) fractalSet_sym_1D;
  
  
  this(short bdm, string cntt, string atp)
  {
    fractalSet_basedim = bdm;
    cnttp = cntt;
    if(bdm == 1)
    {	
      arc_type = atp;
    }
    
    
  }
  
  
  ~this()
  {
  }
  
  
  void initiate(string inFl)
  {
    inputFl = inFl; 			// we don't need a grammar file this time
    
  }
  
  void readFile()
  {
    auto f_ = std.stdio.File(inputFl, "r");
    while(!f_.eof())
    {all_raw ~= f_.readln().chomp();
      all_raw ~= '\n';}
      f_.close();
  }
  
  void readTarget(string directive = "")	// if there is no directive put everything in a single arc
  {
    
    if(directive == "")
    {
      
      
      
      if(arc_type == "string") 
      {
	if(fractalSet_basedim == 1)
	{
	  arc!(string, string[]) sym_arc;		// this is a placeholder arc
	  
	  
	  
	  
	  // get the knot definitions
	  string[] defs = all_raw.split("\n");
	  string[] tkns;
	  
	  string[] coords;
	  string[] arc_coords;
	  string[] abs_coords;
	  
	  
	  string ID;
	  string[] commands;
	  
	  //initiate an arc,
	  arc!(string, string[]) basearc; // this is the single arc to contain ALL our knots
	  arc!(string, string[]) * basearc_p;
	  (basearc).initmark = "null";
	  (basearc).endmark = "omega";
	  basearc.knots = [];
	  basearc_p =  &basearc;
	  // 		    
	  arc!(string, string[]) * targetArc_p, targetArc_p_2;
	  arc!(string, string[]) targetArc;
	  // 		    
	  // you need an initialization knot
	  knot!(string, string[]) Knot, k1, k2;
	  
	  
	  int p_, s_;
	  int kk;
	  bool knot_in = false;
	  
	  foreach(string d; defs)
	  {
	    
	    if(d.chomp() == "")
	      continue;
	    
	    // expect a list
	    
	    if(cnttp == "stringarr")
	    {  
	      tkns = tokenize(d, ' ', ['{','}']);
	      
	      if(tkns[0] != ",") { // raise an error
	      }
	      
	      // d[1] is definitely coordinate
	      coords = tkns[1][1 .. $-1].tokenize(' ', ['{','}']);
	      
	      arc_coords = coords[2][ 1 .. $ -1].chomp().tokenize(' ', ['{','}']);
	      abs_coords = coords[1][ 1 .. $ -1].chomp().tokenize(' ', ['{','}']);
	      
	      
	      
	      
	      
	      // make a knot
	      Knot.prec = abs_coords[1];
	      Knot.succ = abs_coords[2];
	      
	      Knot.ID = tkns[2];
	      
	      Knot.cnt = [tkns[3]]; // do not tokenize them now;
	      Knot.arcp = (arc!(string, string[])*).init;
	      Knot.type = 1 ; // one: contins an id and content, not an arc type
	      
	      
	      targetArc.initmark = arc_coords[1];
	      targetArc.endmark = arc_coords[2];
	      //targetArc.knots = basearc.knots;
	      
	      targetArc_p = &targetArc;
	      
	      
	      targetArc_p = findArc!(arc!(string, string[]))(basearc_p, targetArc_p); 
	      // in this line, targetarc is not a new arc any more
	      // in this line, targetarc is pointing to an existing arc
	      
	      
	      if(targetArc_p.knots.count() == 0)
	      { targetArc_p.knots ~= Knot;}
	      else
	      {
		if(Knot.prec == targetArc_p.initmark && Knot.succ == targetArc_p.knots[0].ID)
		{ targetArc_p.knots = [Knot] ~ targetArc_p.knots;}
		else{
		  for(kk = 0; kk < targetArc_p.knots.count() -1; kk++)
		  {
		    if(targetArc_p.knots[kk].ID == Knot.prec && targetArc_p.knots[kk+1].ID == Knot.succ)
		    {
		      knot_in = true;
		      targetArc_p.knots = targetArc_p.knots[0 .. kk] ~ Knot ~ targetArc_p.knots[ kk + 1 .. $];
		      break;
		    }
		  }
		  
		  if(!knot_in)
		  {
		    if(Knot.prec == targetArc_p.knots[targetArc_p.knots.count()-1].ID && Knot.succ == targetArc_p.endmark)
		      targetArc_p.knots ~= Knot;
		  }
		}
		
	      }
	      
	      // check if targetarc itself has to be inserted somewhere
	      
	      targetArc_p_2 = findParentArc!(arc!(string,string[]))(basearc_p,targetArc_p);
	      
	      
	      
	      if(targetArc_p != targetArc_p_2)
	      {
		
		Knot.type = 2;
		Knot.prec = abs_coords[1];
		Knot.succ = abs_coords[2];
		Knot.ID = targetArc_p.initmark ~ " ... " ~ targetArc_p.endmark;
		Knot.cnt = [];
		Knot.arcp = targetArc_p;
		
		knot_in = false;
		if(targetArc_p_2.knots.count() == 0)
		{ targetArc_p_2.knots ~= Knot;}
		else
		{
		  if(Knot.prec == targetArc_p_2.initmark && Knot.succ == targetArc_p_2.knots[0].ID)
		  {  targetArc_p_2.knots = [Knot] ~ targetArc_p_2.knots;}
		  else{
		    for(kk = 0; kk < targetArc_p_2.knots.count() -1; kk++)
		    {
		      
		      if(targetArc_p_2.knots[kk].ID == Knot.prec && targetArc_p_2.knots[kk+1].ID == Knot.succ)
		      {
			knot_in = true;
			if(kk == 0)
			  targetArc_p_2.knots = [targetArc_p_2.knots[0]] ~ Knot ~ targetArc_p_2.knots[ kk + 1 .. $];
			else if (kk > 0 && kk + 1 < targetArc_p_2.knots.count()-1)
			  targetArc_p_2.knots = targetArc_p_2.knots[0 .. kk] ~ Knot ~ targetArc_p_2.knots[ kk + 1 .. $];
			else if (kk+1 == targetArc_p_2.knots.count()-1)
			  targetArc_p_2.knots = targetArc_p_2.knots[0 .. kk] ~ Knot ~ targetArc_p_2.knots[ kk + 1];
			break;
		      }
		    }
		    
		    if(!knot_in)
		    {
		      if(Knot.prec == targetArc_p_2.knots[targetArc_p_2.knots.count()-1].ID && Knot.succ == targetArc_p_2.endmark)
			targetArc_p_2.knots ~= Knot;
		    }
		  }
		  
		}
		
		
		
		
		
	      }
	      
	      // basearc = targetArc;
	      // basearc_p = &basearc;
	      
	      
	      targetArc_p = new arc!(string, string[]);
	      
	    }
	    
	  }
	  
	  
	  fractalSet_sym_1D.raw = all_raw;
	  fractalSet_sym_1D.arcs = [*basearc_p];
	  
	  
	}
	
	
	
      }
      
      
    }
    
    
  }
  
  
  T * findParentArc(T)(T* searchBegin, T * searchTarg)
  {
    
    
    T a;
    T * aa = new T;
    aa = &a;
    
    
    short k;
    
    
    if(searchTarg.initmark == searchBegin.initmark && searchTarg.endmark == searchBegin.endmark)
    {  return searchBegin;}
    
    if(searchTarg.initmark == searchBegin.initmark && searchTarg.endmark == searchBegin.knots[0].ID)
    {  return searchBegin;}
    
    for(k = 0; k < searchBegin.knots.count(); k ++)
    {
      if(searchBegin.knots[k].type == 2)		//pointer to arc
      {  
	aa = findParentArc(searchBegin.knots[k].arcp, searchTarg);
	if(aa.cnttp == 0)
	{
	  if(searchBegin.knots[k].ID == searchTarg.initmark  && searchBegin.knots[k+1].ID == searchTarg.endmark)
	  {
	    return searchBegin;
	  }
	}
	else
	{
	  return aa;
	}
      }
      else{
	if(searchBegin.knots[k].ID == searchTarg.initmark  && searchBegin.knots[k+1].ID == searchTarg.endmark)
	{
	  return searchBegin;
	}
      }
    }
    
    
    
    
    
    
    // if fails;
    aa.cnttp = 0;
    return aa;
    
    
  }
  
  T * findArc(T)(T * searchBegin, T * searchTarg)
  {
    
    
    
    T a ;
    T * aa = new T;
    
    aa = &a;
    
    short k;
    
    
    
    if(searchTarg.initmark == searchBegin.initmark && searchTarg.endmark == searchBegin.endmark)
    {   return searchBegin;}
    
    
    
    if(searchBegin.knots.count() == 0)
    {	
      aa.cnttp = 0;
      return aa;
    }
    
    
    
    // check first
    
    if(searchBegin.initmark == searchTarg.initmark  && searchBegin.knots[0].ID == searchTarg.endmark)
    {return searchBegin;}
    
    
    
    for(k = 0; k < searchBegin.knots.count()-1; k++)
    {
      
      
      if(searchBegin.knots[k].type == 2) // if an arc pointer
      {
	
	aa = searchBegin.knots[k].arcp;
	aa = findArc(aa, searchTarg);
	if(aa.cnttp != 0)
	{
	  return  aa;
	}
	else
	{
	  
	  if(searchBegin.knots[k].ID == searchTarg.initmark  && searchBegin.knots[k+1].ID == searchTarg.endmark)
	  {
	    // make a new arc, and return
	    aa = new T;
	    aa.initmark = searchTarg.initmark;
	    aa.endmark = searchTarg.endmark;
	    aa.knots = [];
	    
	    T * ab = aa;
	    return aa;
	  }
	  
	  
	  
	}
      }
      else if (searchBegin.knots[k].type == 1)
      {
	
	if(searchBegin.knots[k].ID == searchTarg.initmark  && searchBegin.knots[k+1].ID == searchTarg.endmark)
	{
	  // make a new arc, and return
	  aa = new T;
	  aa.initmark = searchTarg.initmark;
	  aa.endmark = searchTarg.endmark;
	  aa.knots = [];
	  
	  T * ab = aa;
	  return aa;
	}
      }
    }
    
    // check last
    
    
    
    
    if(searchBegin.knots[searchBegin.knots.count()-1].ID == searchTarg.initmark  && searchBegin.endmark == searchTarg.endmark)
    { return searchBegin;}
    
    
    aa.cnttp = 0;
    return aa;
  }
  
  
  
  
}













class tensorReader
{
  
}

class binaryReader
{
  
}

class sentenceReader
{
  
}



class commandParser
{
  
  this(){}
  ~this(){}
  
  
  parseRes[] parse(string command)
  {
    
    
    
    string c = command.chomp();
    
    
    if(c[0] == '{' && c[c.count()-1] == '}')
      command = command[1 .. command.count()-1-1];
      command.chomp();

      string[] commandB = tokenize(command, ' ', ['{','}']);
     
      parseRes[] res;
      parseRes elem, interm;
      string singCommand;
      int i;
      
      switch (commandB[0])
      {
	case "," :
	  //make a plain list, not an array
	  for(i = 1; i < commandB.count(); i++)
	  {
	    singCommand = commandB[i];
	    
	    //if surrounded by {}
	    if (singCommand[0] == '{' && singCommand[$] == '}')
	    {
	      interm.type = 2;
	      interm.compoundRes = parse(singCommand);
	      interm.res = "";
	    }
	    else
	    {
	      interm.type = 1;
	      interm.res = singCommand;
	      interm.compoundRes = [];
	    }
	    
	    res ~= interm;
	  }
	  break;
	  
	default :
	  
	  break;
	  
	  
      }
      return res;
  }
  
}