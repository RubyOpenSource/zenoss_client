# This code is a bit verbose because unfortunately I cannot get the 're' module to work
# in Zope. For some reason it keeps redirecting me to the login page when I try and use it.

# This script depends on the user passing a parameter called "methodName" which maps to a
# Zenoss method to be called. It also depends on a parameter called "args" which is passed
# in the form of an array so we can position the arguments to the method correctly. This
# is done because I could not find a way to use named parameters when the names themselves
# are dynamic.
# How to pass arguments:
# * make sure no spaces exist in your argument list or your browser won't pass them correctly
# * Use '===' to delimit multiple arguments to "args"
# * To embed quotes use a triple quote.  ''' or """
#
# There is now basic support for callbacks.  If you want to get an attribute of an object
# like object.id, set 'id' as the filterAttr:
#   * filterAttr=id
# or if it is a function like object.getName() set the filterFunc:
#   * filterFunc=getName
#
# Example method call:
# http://zenoss1:8080/zport/dmd/Devices/Server/Windows/WMI/server1/callZenossMethod?methodName=getRRDValues&args=[['ProcessorTotalUserTime_ProcessorTotalUserTime','MemoryPagesOutputSec_MemoryPagesOutputSec']]

request = container.REQUEST

# ---------------- Conversion Methods ----------------
# Convert "item" to an appropriate type. This really only handles
# floats, ints, None, True/False, and strings at this time.
# This is for use in map calls
def convertType(item):
  if(item.count('.') == 1):
    items = item.split('.')
    if(items[0].isdigit() and items[1].isdigit()):
      return float(item)
    else:
      return item
  elif(item.isdigit()):
    return int(item)
  elif(item == 'None'):
    return None
  elif(item == 'True'):
    return True
  elif(item == 'False'):
    return False
  else: # Assuming the item is a string
    return item


def convertToList(string, split_char = ','):
  # This strange bit of confusion allows us to pass wanted quotes as arguments.  It first converts
  # them to non-quote chars, replaces unwanted quotes, then converts them back to quotes.  An example
  # of where this is needed is in EventManagerBase.getEventList() function.  It has an argument that
  # is a SQL 'where' statement that needs the embedded quotes.
  nstring = string.replace('"""','---').replace("'''","___")
  nstring = nstring.replace('"','').replace("'","").replace(" ","")
  nstring = nstring.replace('___',"'").replace('---','"')
  if(nstring == "[]"):
    return []
  else:
    return map(convertType, nstring[1:-1].split(split_char))


def convertToTuple(string):
  newtuple = convertToList(string)
  return tuple(newtuple)


def convertToDict(string):
  # See convertToList() description of what is going on here.
  nstring = string.replace('"""','---').replace("'''","___")
  nstring = nstring.replace('"','').replace("'","").replace(" ","")
  nstring = nstring.replace('___',"'").replace('---','"')
  if(nstring == "{}"):
    return {}
  else:
    return dict(map(convertType,item.split(':')) for item in nstring[1:-1].split(','))


# -------------- End Conversion Methods --------------

# ------------- Start Convenience Methods ------------

def isList(item):
  return same_type(item, [])

def callFilterFunc(object):
  return getattr(object, filterFunc)()

def callFilterAttr(object):
  return getattr(object, filterAttr)


# -------------- End Convenience Methods -------------

method = request.form['methodName']
if( request.form.has_key('args') ):
  args = convertToList(request.form['args'],"===")
else:
  args = []

if(request.form.has_key('filterFunc')):
  filterFunc = request.form['filterFunc']
else:
  filterFunc = False

if(request.form.has_key('filterAttr')):
  filterAttr = request.form['filterAttr']
else:
  filterAttr = False

for ind in range(len(args)):
  if( not isinstance(args[ind], str) ):
    args[ind]
  elif( args[ind].find('[') >= 0 ):
    #print "found list", args[ind]
    args[ind] = convertToList(args[ind])
  elif( args[ind].find('(') >= 0 ):
    #print "found tuple", args[ind]
    args[ind] = convertToTuple(args[ind])
  elif( args[ind].find('{') >= 0 ):
    #print "found hash", args[ind]
    args[ind] = convertToDict(args[ind])
  else:
    args[ind]
    # Leave it as a string


#print "Method: ", method
#print "Args: ", args


# Call the method
if(len(args) > 0):
  retval = getattr(context, method)(*args)
else:
  retval = getattr(context, method)()

# Call callback functions if they were passed
if(filterFunc):
  if isList(retval):
    print map(callFilterFunc, retval)
  else:
    print callFilterFunc(retval)
elif(filterAttr):
  if isList(retval):
    print map(callFilterAttr, retval)
  else:
    print callFilterAttr(retval)
else:
  print retval

return printed
