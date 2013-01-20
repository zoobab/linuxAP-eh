#include "setup.h"
#include "dirent.h"

//----------------------------------------------------------------------
// get_file_chooser - Constructs a selection input to choose a file to config
//----------------------------------------------------------------------
char **get_file_chooser(char *dirname, char *value, char *keyword, char *newmsg) {
	DIR *dirp;
	struct dirent *entry;
	char **p, **q, *first;
	int buflen;

	first = NULL;
	p = (char **)bigbuf;
	dirp = opendir(dirname);
// Copy in the field name && default
	*p++ = strdup(keyword);
	buflen += sizeof(char *);
// q is Placeholder for default value
	q = p++; *q = NULL;
	buflen += sizeof(char *);
	if(dirp != NULL) {
		while((entry = readdir(dirp)) != NULL) {
			if(entry->d_name[0] == '.') continue;
			*p++ = strdup(entry->d_name);
			buflen += sizeof(char *);
			*p++ = strdup(entry->d_name);
			buflen += sizeof(char *);
			if(first == NULL) first = *(p-1);
		}
		closedir(dirp);
	}
	*p++ = strdup(newmsg);
	buflen += sizeof(char *);
	*p++ = strdup("__new");
	buflen += sizeof(char *);
	*p++ = NULL;
// Now set the default value
	if(value != NULL) {
		*q = strdup(value);
	} else if (first != NULL) {
		*q = strdup(first);
	} else {
		*q = strdup("__new");
	}
	buflen = p - (char **)bigbuf;
// And malloc & copy the pointers for the char ** array;
	q = malloc(buflen * sizeof(char *));
	memcpy(q, bigbuf, buflen *sizeof(char *));
	return(q);
}

//----------------------------------------------------------------------
// read_cfg - Reads a config file based on 'keyword=value'
//----------------------------------------------------------------------
int read_cfg (char *filename, char *keywords[], char *values[]) {
    FILE *f;
    char *line;
    sprintf(bigbuf,"%s/%s",globs.cfgdir,filename);
    f = fopen(bigbuf,"r");
    if (f == NULL) return 0;
    while (readline(f,bigbuf,BIGBUF_SIZE) >= 0) {
	line=bigbuf;
	while(isspace(*line)) line++;
	if (line[0]!='#' && line[0]!='\n' && line[0]!='\0') // skip non-values
	    read_cfg_value(keywords, values, line);
    }
    fclose(f);
    return 1;
}

//----------------------------------------------------------------------
// read_cfg_value - Reads a copy of a value
//----------------------------------------------------------------------
void read_cfg_value (char *keywords[], char *values[], char *line) {
    int ix = argvindex(keywords,line,strncmp);
    values[ix] = retrieve_cfg_value(keywords,ix,bigbuf);
}

//----------------------------------------------------------------------
// dup_cfg_value - Return a copy of a value from line based on index
//----------------------------------------------------------------------
char *retrieve_cfg_value(char **keywords, int ix, char *line) {
	char *p,*q;
	p = line + strlen(keywords[ix]);
	while(isspace(*p)) p++;
// Strip trailing whitespace
	q = line + strlen(line) - 1;
	while(q > p && isspace(*q))*q-- = 0;
	return(strdup(p));
}

//----------------------------------------------------------------------
// argvindex - Find string s on NULL terminated argv style list argvlist
//----------------------------------------------------------------------
int argvindex(argvlist, s, strfunc)
char *argvlist[];
char *s;
int (*strfunc)();
{
    int index;
    for(index = 0; argvlist[index] != NULL; index++ ) {
        if ( (strfunc)(argvlist[index], s, strlen(argvlist[index])) == 0)
            break;
    }
    return(index);
}

//----------------------------------------------------------------------
// READLINE
//----------------------------------------------------------------------
int     readline(f, buffer, length)
FILE    *f;
char    *buffer;
int     length;
{
        int     cc;
        int     count;
        count = 0;
        while(1) {
                cc = fgetc(f);
                if(cc == EOF) {
                        buffer[count] = 0;
                        return( -(count + 1) );
                }
                if(cc == '\r') {
                        continue;
                }
                if(cc == '\n') {
                        buffer[count] = 0;
                        return( count );
                }
                buffer[count++] = cc;
                if(count >= (length - 1) ) {
                        buffer[count] = 0;
                        return( count );
                }
        }
}

/*----------------------------------------------------------------------
strcpos - return position of char cc in string aa

Modification History:

2003/01/04 Keith Edwin Smith
o Added strrcpos
----------------------------------------------------------------------*/
int strcpos(aa, cc)
const char    *aa;
int    cc;
{
    register int i;
    if(aa == NULL) return(-1);
    for(i=0; *aa && (*aa != cc); i++, aa++);
    if(*aa) return(i);
    return(-1);
}

int strrcpos(aa, cc)
const char    *aa;
int    cc;
{
    register int i;
    register const char *p;

    if(aa == NULL) return(-1);
    p = aa;
    i = 0;
    while(*p) p++, i++;
    for(; p != aa && (*p != cc); i--, p--);
    if(*aa) return(i);
    return(-1);
}


//----------------------------------------------------------------------
// SEL
// Selection
//----------------------------------------------------------------------
char *sel(char *flags, char **arglist) {
	char *p, **ap, *value, *label, *sel;

	ap = arglist;
	p = bigbuf;
	sprintf(p,"<select %s name=\"%s\">\n", flags, *ap++);
	p += strlen(p);
	value = *ap++;
	while(*ap != NULL) {
		sel = "";
		label = *ap++;
		if(*ap == NULL) break;
		if(strcmp(*ap, value) == 0) {
			sel = "selected";
		}
		sprintf(p,"  <option value=\"%s\" %s>%s\n",
			*ap, sel, label);
		ap++;
		p += strlen(p);
	}
	sprintf(p,"</select>");
	return(strdup(bigbuf));
}


//----------------------------------------------------------------------
// FORM
// Returns a malloc'd string to a form tag
//----------------------------------------------------------------------
char *form(char *method, ...)
{
	char *s;
	char *name, *action;

	va_list ap;

	if(*method == '/') {
		return(strdup("</form>"));
	}

	va_start(ap, method);
	
	name = action = "";
	while(1) {
		s = va_arg(ap, char *);
		if(s == NULL) break;
		if(action == "") {
			sprintf(bigbuf,"action=\"%s\"",s);
			action = strdup(bigbuf);
			continue;
		}
		if(name == "") {
			sprintf(bigbuf,"name=%s",s);
			name = strdup(bigbuf);
			continue;
		}
	}
	va_end(ap);
	sprintf(bigbuf,"<form %s method=\"%s\" %s>",
		name, method, action);
	if(*name != 0) {
		free(name);
	}
	if(*action != 0) {
		free(action);
	}
	return(strdup(bigbuf));
}


char *itext(char *name, char *value, int size, int maxlength)
{
	sprintf(bigbuf,
	  "<input type=text name=%s value=\"%s\" size=\"%d\" maxlength=\"%d\">",
		name, value, size, maxlength);
	return(strdup(bigbuf));
}

char *ihid(char *name, char *value)
{
	sprintf(bigbuf,
	  "<input type=hidden name=\"%s\" value=\"%s\">", name, value);
	return(strdup(bigbuf));
}

char *isub(char *name, char *value)
{
	sprintf(bigbuf,
	  "<input type=submit name=\"%s\" value=\"%s\">", name, value);
	return(strdup(bigbuf));
}

char *tabl(char *arg)
{
	if(arg != NULL) {
		return(strdup("</table>"));
	}
	return(strdup("<table>"));
}

char *tr(char *arg)
{
	if(arg != NULL) {
		return(strdup("</tr>"));
	}
	return(strdup("<tr>"));
}

char *th(char *s) {
	sprintf(bigbuf,"<th align=right>%s</th>", s);
	return(strdup(bigbuf));
}

char *td(char *s) {
	sprintf(bigbuf,"<td>%s</td>", s);
	return(strdup(bigbuf));
}
