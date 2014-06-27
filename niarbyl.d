/* the data handling program*/

/** imports **/
import std.getopt , std.stdio, std.string , std.math , std.conv,
std.range, std.algorithm, std.array, std.stream, std.regex;;

import tango.io.Stdout;


/** classes **/

class grammar{

    export string[] enclosers; // encloses either a packet 
			// or a value, 
			// everything inside enclosers 
			// is ignored by Tokenizer
    export string separator;
    export string entry_sep;
    export string content_key;
    export string id_key;
    
    export string trg_keyname = "";
    export string has = "";
    export string lacks = "";

    
    // presently dummy
    
    this()
    { 
    }
    
    ~this()
    {
    }
    
    
    
    

}


class result{
  
    
    export string[] raw;
    export string res;

}







/** globals **/
grammar[] Grammars;
result[] Results;


string inputfl;
string grammarfl;
string searchtrgt;


int[][] boundaries;






/** functions **/


auto subRange(R)(R s, size_t beg, size_t end)
{
      return s.dropExactly(beg).take(end-beg);
}


string deEscapify(string k)
{
    
    if(k == "\\n")
	return "\n";
    if(k == "\b")
	return " ";
    if(k == "\t")
	return "	";
    else
	return k; // for this time ...
}





void loadGrammar()
{
    
    
	
	auto f_ = new std.stdio.File(grammarfl);
	
	int i_ = 0;
	string ln;
	grammar Grammar = new grammar;
	
	while(!f_.eof())
	{
	    
	    while(i_ < 7 && !f_.eof())
	    {
		
		switch(i_)
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
		    Grammar.trg_keyname = ln;
		    
		    
		    case 7:
		    // read the has or lacks command, 
		    // and edit it as necessary
		    ln = f_.readln().chomp();
		    
		    if(ln[0 .. 4] == "has:")
		      Grammar.has = ln[4 .. $]; 
		    else if(ln[0 .. 6] == "lacks:")
		      Grammar.lacks = ln[6 .. $];
		    break;
		    
		    default:
		    break;
		
		}
		
		i_++;

		
	    }
	    Grammars.assumeSafeAppend();
	    Grammars ~= Grammar;
	    
	    
	    
	    i_ = 0;
	    Grammar = new grammar;
	}
	
	f_.close();
	
	
    
}





void setGrammar()
{
    
    grammar[] G;
    grammar g;
    string[] hs;
    string[] ls;
    
    
    foreach(grammar Grm; Grammars)
    {
	
	
	
	if(Grm.has != "")
	{
	    
	    hs = Grm.has.split(",");
	    foreach(string h;hs)
	    {
		g = new grammar;
		g.enclosers = Grm.enclosers;
		
		g.separator = Grm.separator;
		g.entry_sep = Grm.entry_sep;
		g.content_key = Grm.content_key;
		g.id_key = Grm.id_key;
		g.trg_keyname = Grm.trg_keyname;
		
		g.has = h;
		G ~= g;
		
	    }
	
	}
	else if(Grm.lacks != "")
	{
	    
	    ls = Grm.lacks.split(",");
	    foreach(string l;ls)
	    {
		g = new grammar;
		g.enclosers = Grm.enclosers;
		g.separator = Grm.separator;
		g.entry_sep = Grm.entry_sep;
		g.content_key = Grm.content_key;
		g.id_key = Grm.id_key;
		g.trg_keyname = Grm.trg_keyname;
		
		g.lacks = l;
		G ~= g;
		
	    }
	    
	}
    }
    
    Grammars = G;
    
}




int[] getLocations_inFile(string s, string path)
{

    int[] k;
    int i_ = 0;
    auto f = new std.stream.File(path);
    
    
    int ii = to!int(s.count());
    string rd = to!string(f.readString(ii));
    
    
    
    if(rd == s)
	k ~= 0; 
    
    
    
    while(!f.eof())
    {
    
	
	if (rd.count() > 0)
	  rd = rd[1 .. $];
	else
	  rd = "";
	
	i_ ++;

	rd ~= f.getc();
	
	if(rd == s)
	   k ~= i_;
    
    }
    
    
    f.close();
    
    return k;

}


int[] removeUpto(int[] trgar, int lm)
{
    
    
    int[] k = find(trgar, lm);
    if(k == [])
      return [];
    else
      return k[1 .. $];
    
}




void extractBoundaries()
{
    
//     int[] k;
    int[] e1;
    int[] e2;
    
    int[] ee1;
    int[] ee2;
    
    int[] e;
    int[] e_trk;
    
    int[][] te;
    int[][] te_trk;
    
    
    
    

    
    foreach(grammar Grm; Grammars)
    {
    
      e = [];
      e_trk = [];
    
      //locate opening enclosers
      e1 = getLocations_inFile(Grm.enclosers[0], inputfl);
      
      //locate closing enclosers
      e2 = getLocations_inFile(Grm.enclosers[1], inputfl);
      
      
      
      
      // arrange it
      ee1 = e1;
      ee2 = e2;
      while(true)
      {
      
	if(ee1.count() == 0 && ee2.count() == 0)
	    break;
      
	if (ee1.count() == 0)
	{
	    
	    e ~= ee2[0];
	    e_trk ~= 2;
	    ee2 = ee2[1 .. $];
	    continue;
	}
	 
	if (ee2.count() == 0)
	{
	    
	    e ~= ee1[0];
	    e_trk ~= 1;
	    ee1 = ee1[1 .. $];
	    continue;
	}
	 
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
      te_trk ~= e_trk;
      
      
      
    }
    
    
   
   
   // TESTED :so far so good
   
   // Now use the comparators, 
   // to find supersets
   
   int cntr;
   int cntr2;
   
    
   string[] subs, sups;
    
   grammar subg, supg;
   
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
	subg = Grammars[cntr];
	
	
	subs = subg.enclosers;
	
	
	
	for(cntr2 = 0; cntr2 < Grammars.count() ; cntr2++)
	{   
	    if(cntr == cntr2)
	      { skip = true; continue;}
	    if(cntr != cntr2)
	    {
		supg = new grammar;
		supg = Grammars[cntr2];
	    
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
	// we assume that it is ballanced
	
	if (l != -1 && cntr != cntr2-1)
	{
	    
	    // find amin
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
		if(jk != te[cntr].count())
		{
		    if (te[l][kk+1] >= te[cntr][jk] && te[l][kk+1]+supg.enclosers[1].count()-1 <= te[cntr][jk+1])
		    {  
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
	      
	      
	      // now we have the boundary
	      
	      
	     if(ie1 != -1 && ie2 != -1)
	     {
	      if (ie1 == 0 && ie2 == te[cntr].count())
		{ te[cntr] = []; te_trk[cntr] = [];}
	      else if (ie1 == 0 && ie2 != te[cntr].count())
		{ te[cntr] = te[cntr][ie2+1 .. $]; te_trk[cntr] = te_trk[cntr][ie2+1 .. $];}
	      else if (ie1 != 0 && ie2 == te[cntr].count())
		{ te[cntr] = te[cntr][0 .. ie1-1]; te_trk[cntr] = te_trk[cntr][0 .. ie1-1];}
	      else if (ie1 != 0 && ie2 != te[cntr].count())
		{ te[cntr] = te[cntr][0 .. ie1-1] ~ te[cntr][ie2+1 .. $]; te_trk[cntr] = te_trk[cntr][0 .. ie1-1] ~ te_trk[cntr][ie2+1 .. $];}
	     }
	      kk++ ; // you need increment two
	      
	      
	    }
	}
	
	
   }
   
   
   boundaries = te;
   
   
}



ulong regexChk(string haystack, string needle)
{
    
    
    auto r = regex(needle, "g");
    auto m = match(haystack, r);
    int i;
    
    foreach(c; m) {
      i++; }
    
    
    
    return i;
    
    
}






void setGrammarApllicability()
{

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
  auto f = new std.stream.File(inputfl);
  
  int k;
  
  ulong chkrs;
  
  for(int i = 0; i < Grammars.count(); i++)
  {
      b = boundaries[i];
      rdout = "";
      // form the check target
      chkTrgt = Grammars[i].trg_keyname ~ Grammars[i].separator ~ Grammars[i].has;
      
      for(int j = 0; j < b.count(); j = j+2)
      {
	f.seek(b[j], SeekPos.Set) ;
	k = j;
	Stdout(b[j]).nl();
	Stdout(b[j+1]).nl();
	
	while(k <= b[j+1] && !f.eof())
	{
	  rdout = rdout ~ f.getc();
	  
	  k++;
	}
	
	// Now we have chkTrgt
	
	// regexChk !
	chkrs = regexChk(rdout, chkTrgt);
	if(chkrs == 0)
	{
	    boundaries[i] = remove(boundaries[i], j);
	    boundaries[i] = remove(boundaries[i], j+1);
	}
      }
      
  }
  
  f.close();
}




string findTarget()
{

    long i = indexOf(searchtrgt, '.');
    
    string id;
    string trg;
    
    if(i == -1)
    {
    
    }
    else
    {
	id = searchtrgt[0 .. i-1];
	trgt = searchtrgt[i+1 .. $];
    }
    
}


/** und los **/


void main(string[] args)
{
  
 // get invocation switches
 
  getopt(args,
  "inpt", &inputfl,
  "grmr", &grammarfl,
  "trgt", &searchtrgt
  );
  
 // pick up grammer
 // set up global variables
  
  
  
  loadGrammar(); //read Grammar from file
  setGrammar(); // extract lists
  extractBoundaries();
  setGrammarApllicability();
  findTarget();
  
  // TESTED UP TO HERE, NO PROBLEM
  
  
  
  // 
  
  // returnTarget();
 
}