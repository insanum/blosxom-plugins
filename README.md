# blosxom-plugins

Here is a collection of plugins I've created for Blosxom v2/v3. Have fun!

---

## Blosxom v2 Plugin: CategoryTree

Just drop this into your blosxom plugins directory. Then, you can insert the
**$categorytree::display** variable into your flavour files wherever you want
a list of your categories to go.  Each line holds the name of one category,
each one linked to the appropriate place in your blosxom weblog.

By default a tree style list with indents is shown.  This is controlled by
the **$iWantIndents** config variable.  If **$iWantIndents** is set to 0
then then the normal directory path with slashes is displayed.  The
**$iDontWantSlashes** and **$slashReplacement** variables are used to modify
the normal directory path output.

You can also show the number of blogs in each category by setting
**$iWantTheCount** equal to 1.  This will show the number of blogs to the
right of the category name.  A parent category will show the number of
blogs in itself and all children.  If **$showCategoryIfZero** is equal to 1
then an empty category is displayed.  If **$showCountIfZero** is equal to 1
then zero counts are displayed.  Lastly you can specify the text before
and after the count with **$countPreStr** and **$countPostStr**.

The following class identifiers are used for CSS control of the list:

**categorytree**: the unordered list as a whole

**categorytree_item**: a single category item in the unordered list

Note that you will want to run this plugin very early (i.e. before any other
plugins that might modify the entries list).  Rename this plugin to
**01categortytree** or something similar based on your plugin runtime
priority naming scheme.

### Changelog

1.7    now runs during blosxom filter and no longer uses File::Find
       now much faster generation times since disk access is no more
       fixed bug with indents (links were underlining indent spaces)

1.6    fixed bug where File::Find output being parsed incorrectly

1.5    fixed to use configured blosxom file extension instead of .txt

1.4    added newlines to output to html code is easier to read

1.3    now generates XHTML 1.0 strict code

1.2    fixed problem with how the global variable was defined

1.1    initial implementation

---

## Blosxom v2 Plugin: CSS

This plugin allows a visitor to choose which CSS layout they would like
to use when browsing your site.  An important note is that this plugin
does not require JavaScript like the **blosxcss** plugin.  Instead, a 
combination of CGI parameters and Cookies are used.  Note that the cookie
plugin is required for this plugin to function properly.

There are two variables filled in by this plugin that can be used within
your flavour files.  The **$css::display** variable contains the sylesheet
link metatag for the currently selected CSS file.  This variable must be
inserted into your head flavour file (i.e. within the HTML head section).
The second variable is **$css::links** which presents a list of all the
different CSS themes available on your site.

If you don't want to use the **$css::links** list for accessing your various
CSS themes, you can simply tack on the following CGI string to a URL:

**?css=css_name**: where 'css_name' is the name of the CSS theme

This plugin can be modified via the following configuration variables:

**@available_css**: This list defines the order of the labels that are shown
in the **$css::links** unordered list.  Note that for every entry in this list,
there must be a corresponding entry in the **%css_files** hash.

**%css_files**: these are the files that are associated with the CSS selections

**$css_default**: the default CSS selection when none is specified (i.e. not
specified via CGI or Cookie)

**$cookie_name**: the name of the cookie stored at the client

The following class identifiers are used for CSS control of the **css::links**
output:

**css_links**: unordered CSS link list

**css_links_item**: an item in the unordered CSS link list

**css_links_active_item**: an item in the unordered CSS link list
(this one respresents the current CSS theme being displayed)

### Changelog

1.1  initial implementation

---

## Blosxom v2 Plugin: Filesystem

This plugin provides some functions that can be used with **interpolate_fancy**
to provide filesystem like information in your flavour files.

The **dir_list** function provides a list of all elements in a given directory
with each element constructed as a link.  This function takes one argument
called **dir_url** (i.e. directory path from your webroot.  Each directory entry
is tacked to the end of this string when creating the links.  Here is an
example:

```
  <@filesystem.dir_list dir_path="/var/www/pics" dir_url="/pics" output="yes" />
```

The **cat_file** function pulls in the entire contents of a given file.  Here is
an example:

```
  <@filesystem.cat_file file_path="/home/edavis/resume.txt" output="yes" />
```

The **path_basename** function returns the basename of the given path.  Here is
an example:

```
  <@filesystem.path_basename path="$path" output="yes" />
```

Some of this functionality could probably be provided using Server Side
Includes or something of the like but having options are always a good thing.

### Changelog

1.1  implemented

---

## Blosxom v2 Plugin: Geek

This plugin is arguably the lamest, least-useful, most idiotic, extremely
demented, and coolest blosxom plugin there is.  You'll either scratch your
head and say "What the...", or smile and say "That's awesome...".  This
plugin is used to present your stories in normal ascii, hexadecimal, octal,
decimal, binary, memory dump, and any other tranformation that an external
application performs (i.e. swedish chef, jive, h@x0r, etc).

Other than the encoded story output there is a variable filled in by
geek that can be used within your themes.  The **$geek::links** variable
is filled in with an unordered list that contains links to the various
geek encodings of the currently display URL.

If you don't want to use the **$geek::links** list for accessing the geek
encodings you can simply tack on any of the following CGI strings to a URL:

**?geek=dmp**: the wicked memory dump format

**?geek=hex**: hexadecimal format

**?geek=oct**: octal format

**?geek=dec**: decimal format

**?geek=bin**: binary format

**?geek=chf**: swedish chef

**?geek=jve**: jive

**?geek=hxr**: h@x0r

Note that if your using the meta plugin make sure that runs before this
plugin so the meta variables don't get geek'ed and presented in the output
(i.e. rename meta to 00meta or something).  This plugin can be modified via
the following configuration variables:

**$geek_title**: set to 1 to encode the story title

**$geek_body**: set to 1 to encode the story body

**$show_eight_bits**: set to 1 to show all 8 bits for binary encoding (note that
the 8th bit will always be zero for ascii)

**$geek_dump_width**: set this to the number of bytes per row in the memory
dump format (must be a multiple of 2)

**@available_modes**: This list defines the order of the labels that are shown
in the **$geek::links** unordered list.  Note that for every entry in this list,
there must be a corresponding entry in the **%geek_labels** hash.

**%geek_labels**: modify this hash to the labels you want to see in your geek list

**%convert_apps**: This hash defines external applications that can perform a
transformation.  These applications must take input via stdin and spit out the
transformed text via stdout.  This plugin has builtins for the 'nrm', 'dmp',
'hex', 'oct', 'dec', and 'bin' transformations.

The following class identifiers are used for CSS control of the output:

**geek_dump**: span label around the encoded title and/or story

**geek_links**: unordered geek link list

**geek_links_item**: an item in the unordered geek link list

**geek_links_active_item**: an item in the unordered geek link list
(this one respresents the current geek mode being displayed)

### Changelog

1.4  added ability to use external applications for transforming text

1.3  the byte width of the "dump" output is now configurable (x2)

1.2  fixed byte alignment padding problem with the "dump" output

1.1  initial implementation

---

## Blosxom v2 Plugin: Graffiti

This plugin provides a simple text form that allows visitors to your site to
add a brief comment, flame, kudo, splat, whatever.  A **$graffiti::display**
variable is provided that contains two text boxes and a submit button.  One box
is used for entering in new text comments, and another that shows all
previously entered text comments.  The graffiti display can be modified via the
following configuration variables:

**$entries_to_show**: the last N number of entries to show in the graffiti box, 0
means to show all entries

**$entry_separator**: a string that is shown between all graffiti entries
in the text box

**$text_rows**: the number of rows in the graffiti text area

**$text_cols**: the number of columns in the graffiti text area

**$entry_rows**: the number of rows in the graffiti new entry text area

**$entry_rows**: the number of columns in the graffiti new entry text area

**$cachefile**: the location of the cache file holding all the graffiti text

You can also configure this plugin to filter out and deny new entries.
First, you can configure a set of IP addresses that are allowed to submit
new entries.  Second, you create the regex that performs the filtering and
mostly it will be a simple 'or' seperated list of words (i.e. profanity).
The graffiti filtering can be modified via the following configuration
variables:

**$restrict_new_entry_by_ip**: allow new graffiti entries only from a select
set of IP addresses (0 = no, 1 = yes)

**@new_entry_ip_addrs**: list of IP addreses that have new entry submission access

**$filter_new_entries**: turn on new entry filtering (0 = no, 1 = yes)

**$entry_filter**: a regex string that is used to filter out new entries
(i.e. normally an 'or' separated list of words)

When a new graffiti entry is submitted, you can optionally have a response
string displayed back to the client.  The graffiti response can be modified
via the following configuration variables:

**$display_feedback_string**: display a response string after a new entry is
submitted (0 = no, 1 = yes)

**$error_string**: response string to display when a new entry has been
denied/filtered

**$valid_string**: response string to display when a new entry has been accepted

The following class identifiers are used for CSS control of the graffiti
display:

**graffiti**: the graffiti output as a whole

**graffiti_response**: the response from a graffiti input

**graffiti_form**: the graffiti form - text boxes and submit button

**graffiti_text**: the graffiti text area

**graffiti_entry**: the graffiti new entry text area

**graffiti_submit**: the graffiti submit button

This plugin also provides a management interface that allows you to remove
specific graffiti entries that have been submitted.  A **$graffiti::admin**
variable is provided that contains a form showing all the entries with
checkboxes, a password field, and a submit button.  You select which entries
you want removed, enter that password, and click the submit button.  The
graffiti administration interface can be modified via the following
configuration variables:

**$require_password**: require a password to be submitted when administrating
graffiti entries (0 = no, 1 = yes)

**$password**: the password that allows administration of graffiti entries

**$restrict_admin_by_ip**: allow administration only from a select set of IP
addresses (0 = no, 1 = yes)

**@admin_ip_addrs**: list of IP addreses that have administration access

**$new_entry_notifications**: set this to 1 if you want email notifications
when new graffiti entries are submitted

**$remove_entry_notifications**: set this to 1 if you want email notifications
when existing graffiti entries are removed

**$email_addr**: email address to send notifications

**$sendmail**: location of sendmail on your server

The following class identifiers are used for CSS control of the graffiti
admin display:

**graffiti_admin**: the graffiti admin output as a whole

**graffiti_admin_response**: the reponse from a graffiti admin action

**graffiti_admin_form**: the graffiti admin form - check boxes and submit button

**graffiti_admin_table**: the graffiti admin table - check boxes with entries

**graffiti_admin_row**: a row in the graffiti admin table

**graffiti_admin_cell**: a cell in the graffiti admin table

**graffiti_admin_submit**: the graffiti admin submit button and password entry

**graffiti_admin_password**: the graffiti admin password entry

**graffiti_admin_submit_button**: the graffiti admin submit button

Included with this plugin is a 'graffiti' flavour theme.  Drop the file into 
your theme directory, or break it out in the specific flavour files, and then
point your browser to 'index.graffiti'.  You will be presented with a graffiti
admin page which you can use to remove previously submitted entries.  If you
choose not to use this theme, simply use the **$graffiti::admin** variable
anywhere in you existing flavour files to access the graffiti admin interface.

### Changelog

1.3  added email notifications

1.2  lots of changes: max number of entries to show, restrict new
     entries to specific IPs, filter new entries based on content,
     new administration interface for removing previous entries,
     administration access to specific IPs and pasword

1.1  initial implementation

---

## Blosxom v2 Plugin: Headlines

This plugin provides the ability to present a list of headlines for all the
stories found by blosxom.  Each headline in the list is a path based permalink
to the story.  The headlines shown is determined by a function call using
the **interpolate_fancy** plugin.  The arguments to this function describe
which headlines to show and how to show them.  Therefore, you can implement
multiple calls within your flavour files.  Each call can present a completely
different set of headlines (i.e. different categories, different sort methods,
different layout, etc).

You can also configure this plugin to display the number of writeback comments
with each headline.  Note that ONLY the WritebackPlus plugin is currently
supported but it should be easy to support other comment type plugins.

The following configuration variables must be configured properly before
this plugin will work:

**$cachefile**: set this to the file used as the headline cache

**$want_writeback_counts**: if you are going to want writeback counts
tacked on to each headline then set this (1 = on, 0 = off)

**$writeback_dir**: the location of the writeback data (make sure this
variable is set to the same location as that configured in the
WritebackPlus plugin)

**$writeback_file_extension**: the file extension of a writeback data
file (make sure this variable is set to the same file extension as that
configured in the WritebackPlus plugin)

**@monthabbr**: if you are going to use the long date format, modify this
array to the month strings you would like to use

Now the details on how to display a set of headlines within your flavour files.
As already mentioned, you must have the **interpolate_fancy** plugin installed
for this to work.  There is no configuration necessary for the
**interpolate_fancy** plugin so if you haven't already done so, download it
and drop it into your plugin directory.  Once you get familiar with
**interpolate_fancy** you'll get excited about the endless possibilitees.

The headlines **interpolate_fancy** function is simply called **get**.  The
most basic call is as follows:

```
    <@headlines.get output="yes" />
```

This would return an unordered list of all the story headlines on your site.
There are a number of arguments you can pass to the **get** function that are
used to modify the list returned.  Here are the descriptions of each and their
default setting if not passed to the **get** function:

**category**: the category to pull headlines from (default: all categories)

**sort_method**: how to sort the headlines (default: **by_date**)
    The available sort methods are:
    **by_date** sorted by date (newest to oldest)
    **by_date_reverse** sorted by date (oldest to newest)
    **by_path_name** sorted alpha by the story's path
    **by_path_name_reverse** sorted reverse alpha by the story's path
    **by_title** sorted alpha by headline
    **by_title_reverse** sorted reverse alpha by headline

**max_to_show**: the max number of headlines to show in the list (default: all)

**show_dates**: show a date string before the headline, headlines occuring on
the same day fall under the same date headline (1 = yes, 0 = no) (default: 0)

**showLongDates**: show Apr 8, 1973 instead of 4/8/1973 (1 = yes, 0 = no)
(default: 0)

**indent**: indent string inserted before a headline, useful with **show_dates**
for contrast between the date and headline strings (default: "")

**show_wb_count**: show the number of writeback comments after each headline
(1 = on, 0 = off) (default: 0)

**wb_prefix**: the string to prefix the writeback comment count
(default: "")

**wb_postfix**: the string to postfix the writeback comment count
(default: "")

**css_class**: the CSS class identifier to use for the unordered list tag
(default: "")

**css_date_class**: the CSS class identifier to use for the date string list
item (default: "")

**css_item_class**: the CSS class identifier to use for the headline string list
item (default: "")

Here are some examples:

  The following will display the last 10 headlines from the "/sports" category
  with the writeback count for each headline and each count looking like "- N".

```
    <@headlines.get category="/sports"
                    show_wb_count="1"
                    wb_prefix="- "
                    max_to_show="10"
                    output="yes" />
```

  The following will display the last 30 headlines (any category) with the
  writeback count for each headline and each count looking like "-N-".

```
    <@headlines.get show_wb_count="1"
                    wb_prefix="-"
                    wb_postfix="-"
                    max_to_show="30"
                    output="yes" />
```

  The following will display all headlines sorted alphabetically by the title
  string.

```
    <@headlines.get sort_method="by_title"
                    output="yes" />
```

  The following will display the last 25 headlines (any category) with the
  date headers.  Also specified are some CSS class identifiers.

```
    <@headlines.get show_dates="1"
                    max_to_show="25"
                    css_class="headlines"
                    css_date_class="headlines_date"
                    css_item_class="headlines_item"
                    output="yes" />
```

  The following will display the last 100 headlines from the
  "/computers/software/blosxom" category sorted in reverse date order
  (i.e. from oldest to newest).  Long date strings will be inserted into
  the headline list and each headline will be indented four spaces and
  show a writeback count looking like "(N)".  Also specified are some
  CSS class identifiers.

```
    <@headlines.get category="/computers/software/blosxom"
                    sort_method="by_date_reverse"
                    show_dates="1"
                    show_long_dates="1"
                    indent="&nbsp;&nbsp;&nbsp;&nbsp;"
                    max_to_show="100"
                    show_wb_count="1"
                    wb_prefix="("
                    wb_postfix=")"
                    css_class="blosxom_headlines"
                    css_date_class="blosxom_headlines_date"
                    css_item_class="blosxom_headlines_item"
                    output="yes" />
```

As you can see from the above examples, these **interpolate_fancy** functions
are very easy to use and also very powerful.  Hopefully these examples are
enough to help you on your way to creating an awesome site.

Note that you will want to run this plugin very early (i.e. after the entry
dates have been set and before any other plugins that might modify the entries
list during the filter routine).  Rename this plugin to **01headlines** or
something similar based on your plugin runtime priority naming scheme.

The cache file is automatically created if it doesn't exist and the CGI
parameter setting **?reindex=y** will force the cache file be re-generated.
Note that the original headline cache file is not compatible with that used
by this new deviation of the headlines plugin.

### Changelog

2.1 deviation from original headlines v1.10 with lots of changes:
    almost a complete rewrite, added ability to get headlines on a per
    category basis, and added ability to show the number of writeback
    comments per headline

---

## Blosxom v2 Plugin: RenderTime

This plugin is used to figure out how long it is taking for Blosxom to render
a page.  Drop this file into your blosxom plugins directory and make sure
it is the first plugin that will be run (i.e. rename to **00rendertime** or
something similar based on your plugin runtime priority naming scheme).
Then for each request this plugin will oompute the render time and log that
time to the configured location.  The log times are in seconds and are of
the form x.xxxx.  The following configuration variables are available:

**$logToErrorLog**: log render times to the web server error log (1 = yes, 0 = no)

**$logToFile**: log render times to a file (1 = yes, 0 = no)

**$logFile**: the location of the log file to write render times to

**$logToPage**: log the render time to the generated page (1 = yes, 0 = no)

**$replacement_string**: the string to search for and replace with the render
time in the generated page

When the **$logToPage** option is turned ON then a render time is computed
in the **last** routine.  The **last** routine is called by Blosxom before the
page is sent to the client.  This allows the render time to be injected into
the outgoing page wherever the **$replacement_string** is found.  Therefore,
this render time will not be completely accurate.  Make note of whatever
plugins run after this plugins in the **last** and **end** routines as these
calls will not be part of the computed time.

The **$logToErrorLog** and **$logToFile** options always compute the render time
in the **end** routine.  Therefore, these times are a bit more accurate.  Also,
for these two options the request URI is also logged as well.

This plugin requires the **gettimeofday** system call.

### Changelog

1.5  added ability to inject the render time within the page itself

1.4  changed to run in the end routine and log entire the request URI
     including any query parameters

1.2  initial implementation

---

## Blosxom v2 Plugin: Tasks

This plug-in provides a **$tasks::display** variable that shows a table of
tasks and the percentage complete for each task.

**$cachefile**: the location of the cache file holding all the task information

**$tasks_graph_char**: the character to use in the percentage complete gant chart
(note that this could be a link to link to an image which represents a unit in
a bar graph)

**$tasks_max_graph_length**: The maximum width (in characters) the percentage
complete gant chart can consume

The following class identifiers are used for CSS control of the table:

**tasks**: the task display output as a whole

**tasks_table**: the task table

**tasks_row**: a row in the task table

**tasks_task**: the task description cell in a task row

**tasks_percentage**: the percentage done cell in a task row

**tasks_graph**: the percentage graph cell in a task row

This plugin also provides a management interface that allows you to submit new
tasks, remove finished tasks, or modify existing tasks.  A **$tasks::admin**
variable is provided that contains a form showing all the tasks descriptions
and percentages in text edit boxes, task remove checkboxes, a password field,
and a submit button.  You modify the data how you want, enter that password,
and click the submit button.  The tasks administration interface can be
modified via the following configuration variables:

**$require_password**: require a password to be submitted when administrating
tasks (0 = no, 1 = yes)

**$password**: the password that allows administration of the task information

**$restrict_admin_by_ip**: allow administration only from a select set of IP
addresses (0 = no, 1 = yes)

**@admin_ip_addrs**: list of IP addreses that have administration access

**$task_notifications**: set this to 1 if you want email notifications
when the task list is modified

**$email_addr**: email address to send notifications

**$sendmail**: location of sendmail on your server

The following class identifiers are used for CSS control of the task
admin display:

**tasks_admin**: the task admin output as a whole

**tasks_admin_response**: the response from a task admin action

**tasks_admin_form**: the task admin form - check boxes, text fields, and
submit button

**tasks_admin_table**: the task admin table - check boxes and text fileds

**tasks_admin_row**: a row in the task admin table

**tasks_admin_remove_checkbox**: the remove checkbox cell in the row

**tasks_admin_task_descr**: the task description cell in the row

**tasks_admin_task_descr_field**: the task description edit box

**tasks_admin_task_percentage**: the task percentage cell in the row

**tasks_admin_task_percentage_field**: the task percentage edit box

**tasks_admin_submit**: the task admin submit button and password entry

**tasks_admin_password**: the task admin password entry

**tasks_admin_submit_button**: the task admin submit button

Included with this plugin is a 'tasks' flavour theme.  Drop the file into 
your theme directory, or break it out in the specific flavour files, and then
point your browser to 'index.tasks'.  You will be presented with a task
admin page which you can use to edit previously submitted tasks.  If you
choose not to use this theme, simply use the **$tasks::admin** variable
anywhere in you existing flavour files to access the task admin interface.

### Changelog

1.2  added email notifications

1.1  initial implementation

---

## Blosxom v3 Plugin: CategoryTree

This plugin provides a **$Plugin::CategoryTree::display** variable that can be
used in your flavour files wherever you want a list of your categories to go.
Each line holds the name of one category, each one linked to the appropriate
place in your Blosxom weblog.

By default a tree style list with indents is shown.  This is controlled by
the **$iWantIndents** config variable.  If **$iWantIndents** is set to 0
then then the normal directory path with slashes is displayed.  The
**$iDontWantSlashes** and **$slashReplacement** variables are used to modify
the normal directory path output.

You can also show the number of blogs in each category by setting
**$iWantTheCount** equal to 1.  This will show the number of blogs to the
right of the category name.  A parent category will show the number of
blogs in itself and all children.  If **$showCategoryIfZero** is equal to 1
then an empty category is displayed.  If **$showCountIfZero** is equal to 1
then zero counts are displayed.  Lastly you can specify the text before
and after the count with **$countPreStr** and **$countPostStr**.

The following class identifiers are used for CSS control of the list:

**categorytree**: the unordered list as a whole

**categorytree_item**: a single category item in the unordered list

To run this plugin simply drop this file into your Blosxom plugin directory
and add **$Plugin::CategoryTree::Run** to your **handlers.flow** file.  Note that
you will want to run this plugin very early (i.e. before any other plugins that
might modify the entries list).

### Changelog

3.1    ported for use with Blosxom 3

---

## Blosxom v3 Plugin: Geek

This plugin is arguably the lamest, least-useful, most idiotic, extremely
demented, and coolest Blosxom plugin there is.  You'll either scratch your
head and say "What the...", or smile and say "That's awesome...".  This
plugin is used to present your stories in normal ascii, hexadecimal, octal,
decimal, binary, and the wicked memory dump form.

Other than the encoded story output there is a variable filled in by
geek that can be used within your themes.  The **$Plugin::Geek::links**
variable is filled in with an unordered list that contains links to the
various geek encodings of the currently display URL.

If you don't want to use the **$Plugin::Geek::links** list for accessing the
geek encodings you can simply tack on any of the following CGI strings to
a URL:

**?geek=dmp**: the wicked memory dump format

**?geek=hex**: hexadecimal format

**?geek=oct**: octal format

**?geek=dec**: decimal format

**?geek=bin**: binary format

This plugin can be modified via the following configuration variables:

**$geekTitle**: set to 1 to encode the story title

**$geekBody**: set to 1 to encode the story body

**$showEightBits**: set to 1 to show all 8 bits for binary encoding (note that
the 8th bit will always be zero for ascii)

**$geekDumpWidth**: set this to the number of bytes per row in the memory
dump format (must be a multiple of 2)

**%labels**: modify this list to the labels you want to see in your geek list

The following class identifiers are used for CSS control of the output:

**geek_dump**: span label around the encoded title and/or story

**geek_links**: unordered geek link list

**geek_links_item**: an item in the unordered geek link list

**geek_links_active_item**: an item in the unordered geek link list
(this one respresents the current geek mode being displayed)

To run this plugin simply drop this file into your Blosxom plugin directory
and add **$Plugin::Graffiti::Init** to your **handlers.flow** file and
**$Plugin::Geek::Encode** to you **handlers.entry** file.  Note that if your
using the meta plugin make sure that runs before this plugin so the meta
variables don't get geek'ed and presented in the output.

### Changelog

3.1    ported for use with Blosxom 3

---

## Blosxom v3 Plugin: Graffiti

This plugin provides a simple text form that allows visitors to your site to
add a brief comment, flame, kudo, splat, whatever.  A **$Plugin::Graffiti::display**
variable is provided that contains two text boxes and a submit button.  One box
is used for entering in new text comments, and another that shows all
previously entered text comments.  The graffiti display can be modified via the
following configuration variables:

**$entries_to_show**: the last N number of entries to show in the graffiti box, 0
means to show all entries

**$entry_separator**: a string that is shown between all graffiti entries
in the text box

**$text_rows**: the number of rows in the graffiti text area

**$text_cols**: the number of columns in the graffiti text area

**$entry_rows**: the number of rows in the graffiti new entry text area

**$entry_rows**: the number of columns in the graffiti new entry text area

**$cachefile**: the location of the cache file holding all the graffiti text

You can also configure this plugin to filter out and deny new entries.
First, you can configure a set of IP addresses that are allowed to submit
new entries.  Second, you create the regex that performs the filtering and
mostly it will be a simple 'or' seperated list of words (i.e. profanity).
The graffiti filtering can be modified via the following configuration
variables:

**$restrict_new_entry_by_ip**: allow new graffiti entries only from a select
set of IP addresses (0 = no, 1 = yes)

**@new_entry_ip_addrs**: list of IP addreses that have new entry submission access

**$filter_new_entries**: turn on new entry filtering (0 = no, 1 = yes)

**$entry_filter**: a regex string that is used to filter out new entries
(i.e. normally an 'or' separated list of words)

When a new graffiti entry is submitted, you can optionally have a response
string displayed back to the client.  The graffiti response can be modified
via the following configuration variables:

**$display_feedback_string**: display a response string after a new entry is
submitted (0 = no, 1 = yes)

**$error_string**: response string to display when a new entry has been
filtered/denied

**$valid_string**: response string to display when a new entry has been accepted

The following class identifiers are used for CSS control of the graffiti
display:

**graffiti**: the graffiti output as a whole

**graffiti_response**: the response from a graffiti input

**graffiti_form**: the graffiti form - text boxes and submit button

**graffiti_text**: the graffiti text area

**graffiti_entry**: the graffiti new entry text area

**graffiti_submit**: the graffiti submit button

This plugin also provides a management interface that allows you to remove
specific graffiti entries that have been submitted.  A **$Plugin::Graffiti::admin**
variable is provided that contains a form showing all the entries with
checkboxes, a password field, and a submit button.  You select which entries
you want removed, enter that password, and click the submit button.  The
graffiti administration interface can be modified via the following
configuration variables:

**$require_password**: require a password to be submitted when administrating
graffiti entries (0 = no, 1 = yes)

**$password**: the password that allows administration of graffiti entries

**$restrict_admin_by_ip**: allow administration only from a select set of IP
addresses (0 = no, 1 = yes)

**@admin_ip_addrs**: list of IP addreses that have administration access

The following class identifiers are used for CSS control of the graffiti
admin display:

**graffiti_admin**: the graffiti admin output as a whole

**graffiti_admin_response**: the reponse from a graffiti admin action

**graffiti_admin_form**: the graffiti admin form - check boxes and submit button

**graffiti_admin_table**: the graffiti admin table - check boxes with entries

**graffiti_admin_row**: a row in the graffiti admin table

**graffiti_admin_cell**: a cell in the graffiti admin table

**graffiti_admin_submit**: the graffiti admin submit button and password entry

**graffiti_admin_password**: the graffiti admin password entry

**graffiti_admin_submit_button**: the graffiti admin submit button

Included with this plugin is a 'graffiti' flavour theme.  Drop the file into 
your theme directory, or break it out in the specific flavour files, and then
point your browser to 'index.graffiti'.  You will be presented with a graffiti
admin page which you can use to remove previously submitted entries.  If you
choose not to use this theme, simply use the **$Plugin::Graffiti::admin** variable
anywhere in you existing flavour files to access the graffiti admin interface.

To run this plugin simply drop this file into your Blosxom plugin directory
and add **$Plugin::Graffiti::Run** to your **handlers.flow** file.

### Changelog

3.2  lots of changes: max number of entries to show, restrict new
     entries to specific IPs, filter new entries based on content,
     new administration interface for removing previous entries,
     administration access to specific IPs and pasword

3.1  ported for use with Blosxom 3

---

## Blosxom v3 Plugin: Headlines

This plugin provides a **$Plugin::Headlines::display** variable that contains
a list of headlines for all the stories found by Blosxom.  Each headline in the
list is a path based permalink to the story.  The headlines presented can be
modified via the following configuration variables:

**$sortByDate**: set to 1 for headlines sorted by date (earliest to latest)

**$sortByDateReverse**: set to 1 for headlines sorted by date (latest to earliest)

**$sortByFilePathName**: set to 1 for headlines sorted by the stories path/file name

**$sortByTitleAlphabetical**: set to 1 for headlines sorted alphabetically

**$numHeadlinesToShow**: the number of headlines to show in the list (0 means all)

**$showDates**: show a date string before the headline (headlines occuring on the
same day fall under the same date headline)

**$indent**: indent string inserted before a headline when **$showDates** is on

**$showLongDates**: show Jan 1, 2003 instead of 1/1/2003

Note that **$sortByDate**, **$sortByDateReverse**, **$sortByFilePathName**, and
**$sortByTitleAlphabetical** are mutually exclusive so only set one of them.
**$showDates** only works when either **$sortByDate** or **$sortByDateReverse**
is being used.  The following class identifiers are used for CSS control of the
list:

**headlines**: the unordered list as a whole

**headlines_date**: a single headline date item in the unordered list

**headlines_item**: a single headline item in the unordered list

To run this plugin simply drop this file into your Blosxom plugin directory
and add **$Plugin::Headlines::Run** to your **handlers.flow** file.  Note that
you will want to run this plugin very early (i.e. before any other plugins that
might modify the entries list).

The cache file is automatically created if it doesn't exist and the CGI
parameter setting **?reindex=y** will force the cache file be re-generated.

### Changelog

3.1    ported for use with Blosxom 3

---

## Blosxom v3 Plugin: RenderTime

This plugin is used to figure out how long it is taking for Blosxom to render a
page.  Drop this file into your Blosxom plugins directory and add
**$Blosxom::Plugin::RenderTime::Start** right after the call to
**$Blosxom::get_plugins** and **$Blosxom::Plugin::RenderTime::Stop** right before
the call to **$Blosxom::output_response** in your **handlers.flow** file.
Then for each request this plugin will oompute the render time and log that
time to the configured location.  The log times are in seconds and are of
the form x.xxxx.  The following configuration variables are available:

**$logToErrorLog**: log render times to the web server error log (1 = yes, 0 = no)

**$logToFile**: log render times to a file (1 = yes, 0 = no)

**$logFile**: the location of the log file to write render times to

**$logToPage**: log the render time to the generated page (1 = yes, 0 = no)

**$replacement_string**: the string to search for and replace with the render
time in the generated page

When the **$logToPage** option is turned ON then a render time is computed
in the **last** routine.  The **last** routine is called by Blosxom before the
page is sent to the client.  This allows the render time to be injected into
the outgoing page wherever the **$replacement_string** is found.  Therefore,
this render time will not be completely accurate.  Make note of whatever
plugins run after this plugins in the **last** and **end** routines as these
calls will not be part of the computed time.

The **$logToErrorLog** and **$logToFile** options always compute the render time
in the **end** routine.  Therefore, these times are a bit more accurate.  Also,
for these two options the request URI is also logged as well.

This plugin requires the **gettimeofday** system call.

### Changelog

3.2  added ability to inject the render time within the page itself

3.1  ported for use with Blosxom 3

---

## Blosxom v3 Plugin: Tasks

This plug-in provides a **$Plugin::Tasks::display** variable that shows a table of
tasks and the percentage complete for each task.

**$cachefile**: the location of the cache file holding all the task information

**$tasks_graph_char**: the character to use in the percentage complete gant chart
(note that this could be a link to link to an image which represents a unit in
a bar graph)

**$tasks_max_graph_length**: The maximum width (in characters) the percentage
complete gant chart can consume

The following class identifiers are used for CSS control of the table:

**tasks**: the task display output as a whole

**tasks_table**: the task table

**tasks_row**: a row in the task table

**tasks_task**: the task description cell in a task row

**tasks_percentage**: the percentage done cell in a task row

**tasks_graph**: the percentage graph cell in a task row

This plugin also provides a management interface that allows you to submit new
tasks, remove finished tasks, or modify existing tasks.  A **$Plugin::Tasks::admin**
variable is provided that contains a form showing all the tasks descriptions
and percentages in text edit boxes, task remove checkboxes, a password field,
and a submit button.  You modify the data how you want, enter that password,
and click the submit button.  The tasks administration interface can be
modified via the following configuration variables:

**$require_password**: require a password to be submitted when administrating
tasks (0 = no, 1 = yes)

**$password**: the password that allows administration of the task information

**$restrict_admin_by_ip**: allow administration only from a select set of IP
addresses (0 = no, 1 = yes)

**@admin_ip_addrs**: list of IP addreses that have administration access

The following class identifiers are used for CSS control of the task
admin display:

**tasks_admin**: the task admin output as a whole

**tasks_admin_response**: the response from a task admin action

**tasks_admin_form**: the task admin form - check boxes, text fields, and
submit button

**tasks_admin_table**: the task admin table - check boxes and text fileds

**tasks_admin_row**: a row in the task admin table

**tasks_admin_remove_checkbox**: the remove checkbox cell in the row

**tasks_admin_task_descr**: the task description cell in the row

**tasks_admin_task_descr_field**: the task description edit box

**tasks_admin_task_percentage**: the task percentage cell in the row

**tasks_admin_task_percentage_field**: the task percentage edit box

**tasks_admin_submit**: the task admin submit button and password entry

**tasks_admin_password**: the task admin password entry

**tasks_admin_submit_button**: the task admin submit button

Included with this plugin is a 'tasks' flavour theme.  Drop the file into 
your theme directory, or break it out in the specific flavour files, and then
point your browser to 'index.tasks'.  You will be presented with a task
admin page which you can use to edit previously submitted tasks.  If you
choose not to use this theme, simply use the **$Plugin::Tasks::admin** variable
anywhere in you existing flavour files to access the task admin interface.

### Changelog

3.1    initial implementation

