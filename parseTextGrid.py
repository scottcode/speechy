'''
parseTextGrid.py

Purpose: to read in TextGrid files 
    (which are created with Praat for annotation of sound files)

Output: object which is a dictionary of dictionaries (Python object type), with the following key-value pairs (typically)
    object
        main
            Object class    = "TextGrid" (usually)
            File type        = "ooTextFile" (if TextGrid saved in long format; if saved in shortened format, this script will not work)
            xmin            = start time of the whole sound file (usually zero)
            xmax            = end time of the whole sound file (if xmin was zero, then xmax is the length of the sound file)
            size            = number of tiers in this TextGrid (digit as string) 
            
        item
            1                (item#)
                xmin        =interval start time (msec, as string of digits)
                xmax        =interval end time
                class        e.g. "Interval Tier"
                name        =name of [item#]'th tier
                intervals
                    1        interval 1 in tier 1
                        xmin
                        xmax
                        text    =text that was typed into this interval. = empty string ('') if nothing there
                        
                
                
            
            
     
Created on Aug 6, 2012

@author: Scott Hajek
'''

def textgrid(filepath):
    import re
    
    # read in file
    #filepath = "/Volumes/Shared/Lab_onGreen/Ryan/Big Ben/Analog Absolutes/AASub21/status_1_5_6/21abs_214_6_right_c_2_9_p_bmp.RAS.TextGrid"
    f = open(filepath)
    lines = f.readlines()
    
    # create RegExObjects to be used in later pattern matching
    parentRE = re.compile('(item|intervals)\s{0,1}\[{0,1}\]{0,1}:')  # e.g. 'item []:' or 'intervals: size = 3'
    nodeRE = re.compile('(item|intervals)\s+\[(\d+)\]:')  # e.g. 'item [2]:' or 'intervals [2]:'
    keyvalRE = re.compile('\s*=\s*')    # e.g. ' = ' as in 'xmax = 3.309'
    
    # Create data variable as dictionary with top-level key as 'main'
    data = {'main' : {}}
    
    # initialize variables to be first used within the FOR loop below
    parent=""
    itemindex = 0
    intervalindex = 0
#    embedlevel=0
    newitem = False
    newinterv = False
    newitemelement=False
    newintervelement=False
    linecount=0
    
    # FOR loop for each line of the input file
    for line in lines:
        linecount=linecount+1
        # If the line contains a node definition (e.g. item [3]: ) then get the node info (nodetuple = (nodename,index))
        if parentRE.search(line) != None:
            parentmatch = parentRE.search(line)
            parent = parentmatch.group(1)
            if parent=="item":
                data.update({"item":{}})  #["item"] = dict()
#                embedlevel = 1
                newitem = True
                (newinterv,newintervelement)=(False,False)
            elif parent=="intervals":
                data["item"][itemindex].update({"intervals" : {}})
#                embedlevel = 2
                newinterv = True
                (newitem,newitemelement)=(False,False)
            else:
                print "parent loop didn't work in input line # "+str(linecount)
        elif nodeRE.search(line) != None:
            nodetuple = nodeRE.search(line)
            if nodetuple.group(1)=="item":
                itemindex = int(nodetuple.group(2))
                data["item"].update({itemindex : {}})
                newitemelement=True
                (newinterv,newintervelement)=(False,False)
            elif nodetuple.group(1) =="intervals":
                intervalindex = int(nodetuple.group(2))
                data["item"][itemindex]['intervals'].update({intervalindex : {}})
                newintervelement=True
                (newitem,newitemelement)=(False,False)
            else:
                print "node loop didn't work, input line # "+str(linecount)
        elif len(keyvalRE.split(line))>1:
            keyval = keyvalRE.split(line)
            keyval = [s.strip() for s in keyval]
            kvdict = {keyval[0] : keyval[1]}
    
            if not (newitem or newitemelement or newinterv or newintervelement):
                data["main"].update(kvdict)
            elif newitemelement:  #itemindex > 0 and (intervalindex == 0 or newinterv):
                data["item"][itemindex].update(kvdict)
            elif newintervelement:  #(intervalindex > 0 and itemindex > 0)
                data["item"][itemindex]["intervals"][intervalindex].update(kvdict)
            else:
                print "problem in element part"
            if newinterv:
                newitem=False
                newitemelement=False
            if newitem:
                newinterv=False
                newintervelement=False
        #else:
        #    print "Input line # "+str(linecount)+" ignored or unrecognized"
    return data

# test out the function textgrid as defined above

#filepath = "/Volumes/Shared/Lab_onGreen/Ryan/Big Ben/Analog Absolutes/AASub21/status_1_5_6/21abs_214_6_right_c_2_9_p_bmp.RAS.TextGrid"
#test=textgrid(filepath)
