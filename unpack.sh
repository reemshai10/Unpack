#!/bin/bash


# in this program we extract files like (GZ.BZ2.Z.ZIP) - and extract recursively by folder , you able to use in the command line like -r / -r / -h 
# -r is recursively extract
# -v is verbose extract
# -h is for help .



#recursively Function for extract all the archive in the flder and all the archive inside the archive ... until no more subfolder/archive to extract
decompress_all_complete () {
    decompress_all () {
        for i in ./* 
        do
        TEMP=`file $i`
        case "$TEMP" in
        *directory*)
                cd "$i"
                find . -type f -name "*.zip" -exec unzip {} +
                if [ "$?" -eq "0" ]
                    then
                    decompress_all
                    cd ..
                    else
                    cd .. 
                fi     
                ;;
            *Zip*)
                unzip -o "$i" > /dev/null
                if [ "$?" -eq "0" ] 
                    then 
                    rm -r "$i"
                    let counter++    
                    else
                    echo "Error - cant extract the $i "     
                fi
                for j in ./*
                do 
                    TEMP=`file $j`
                    case "$TEMP" in
                    *directory*)
                            cd "$j"
                            decompress_all
                            cd ..
                            ;;
                            
                            
                    esac
                done            
                ;;
            *gzip*)
                gzip -d "$i" -kf
                if [ "$?" -eq "0" ]
                    then
                    rm -r "$i"
                    let counter++
                    else
                    echo "Error - cant extract the $i "     
                fi
                for j in ./*
                do 
                    TEMP=`file $j`
                    case "$TEMP" in
                    *directory*)
                            cd "$j"
                            decompress_all
                            cd ..
                            ;;
                            
                    esac
                done            
                ;;
            *bzip2*)
                bzip2 -d "$i" -kf
                if [ "$?" -eq "0" ]
                    then
                    rm -r "$i"
                    let counter++
                    else
                    echo "Error - cant extract the $i "     
                fi 
                for j in ./*
                do 
                    TEMP=`file $j`
                    case "$TEMP" in
                    *directory*)
                            cd "$j"
                            decompress_all
                            cd ..
                            ;;
                            
                    esac
                done            
                ;;
            *compress*)
                    uncompress -f "$i"
                if [ "$?" -eq "0" ]
                    then
                    rm -r "$i"
                    let counter++
                    else
                    echo "Error - cant extract the $i "     
                fi 
                for j in ./*
                do 
                    TEMP=`file $j`
                    case "$TEMP" in
                    *directory*)
                            cd "$j"
                            decompress_all
                            cd ..
                            ;;
                            
                    esac
                done            
                ;;   

            *)
                
                CHECKMAINFILE="`PWD`"
                if [ "$CURRENT" == "$CHECKMAINFILE" ]
                    then
                    let COUNTER_UNEXTRAT++
                fi    
                
                ;; 
        esac
    done
    } 
    decompress_all
    for i in ./*
        do 
        TEMP=`file $i`
        case "$TEMP" in
            *directory*)
                cd $i
                decompress_all
                cd ..
                ;;
                
        esac
    done            
}


# all the loop for extract any kind of archive or switch -v/-r




# Global variable
 COUNTER_FILE=0
 counter=0
 SUCCESS=1
 VERBOSE=1
 COUNTER_UNEXTRAT=0
 CHECKIPUT=0
 RES=$#
 CURRENT=`pwd`
 BASENAME=`basename "$CURRENT"`












# check if there any argument
if [ -z "$1" ]
 then
    echo "$1 Error-Didnt get any argument" 
    exit 1
fi


while [ ! -z "$1" ]   # loop over all our argument unull is empty 
    do
    case "$1" in  
        -v)
            if [ "$VERBOSE" -eq "0" ]   
             then
                break   # we break in case we got in the command EXPALE: * -v
             else
                let VERBOSE=0   # this case we looking for argument -v and if there we Reduce the argument -v for counting the number of files
                RES="$((RES-1))"
                shift
             fi   
             ;;
                
        -r)
            if [ "$VERBOSE" -eq "1" ]     
              then
                if [ "$CHECKIPUT" -eq "1" ] 
                then
                  break    #  # we break in case we got in the command EXPALE: some-folder -r 
                else 
                   let VERBOSE=1 
                   shift
                fi  
              else
                 let VERBOSE=1   # we make sure our flag is up 
                 shift
            fi           
           ;;
         -h) # help swich
            printf  "switch: -v : echo​​ each file decompressed & warn for each file that was NOT decompressed\nswitch: -r :will traverse contents of folders recursively, performing unpack on each\n " 
            exit 1;;    
        *)
            if [ "$RES" -gt "1" ]     # all the loop/case we only cover that if any case the user put diffrent the argument r:v 
                then
                    for i in $@
                     do
                      case "$i" in 
                         -v)
                            if [ "$VERBOSE" -eq "0" ]
                                then
                                    break
                                else
                                    let VERBOSE=0
                                    RES="$((RES-1))"
                                fi   
                            
                            ;;
                        -r)
                             if [ "$VERBOSE" -eq "1" ]
                                then
                                    let CHECKIPUT=1
                                else
                                    let VERBOSE=1
                                fi   
                        ;;
                     esac
                    done    
            fi
        ;; 
            
                        
         
     esac


     FILETYPE=`file $1`      # we check what type is it to extract  that type of file this is for all (zip,bzip,gzip,compress,directory) 
        case "$FILETYPE" in
        *Zip*)
            unzip -o "$1" > /dev/null 
            let SUCCESS=$?
            if [ "$SUCCESS" -eq "0" ] 
             then
                let counter++
            fi
            ;;
        *gzip*)
            gzip -d "$1" -kf 
             let SUCCESS=$?
            if [ "$SUCCESS" -eq "0" ]
             then
                let counter++ 
            fi
            ;;
       *bzip2*)
            bzip2 -d "$1" -kf  
             let SUCCESS=$?
            if [ "$SUCCESS" -eq "0" ]
             then
                let counter++
            fi
            ;;
         *compress*)
            
            if [ ! "$1" == "*/.Z" ]
             then
                mv "$1" "$1.Z"
            fi

            uncompress -f "$1" 
            let SUCCESS=$?   
            if [ "$SUCCESS" -eq "0" ]
             then
                let counter++
            fi
            ;;
        *directory*)  # in this case we dooing to things, ONE-UNPKING ALL THE FILES IN THE FOLDER ,TWO- make a call to our recursively fun the extract all the archive-arhive and .... 
            cd $1
            RES="$((RES-1))"
            CURRENT=`pwd`
            BASENAME=`basename "$CURRENT"`
            for f in ./*
             do
                TYPE=`file $f`
                case "$TYPE" in
                  *Zip*)
                    if [ "$VERBOSE" -eq "0" ]
                     then
                        unzip -o "$f" > /dev/null 
                        let SUCCESS=$?
                        if [ "$SUCCESS" -eq "0" ]  # this is for the call -v folder
                        then
                            let counter++
                            let COUNTER_FILE++
                            echo "Unpacking $f"
                        fi
                     else # for -r folder
                      unzip -o "$f" > /dev/null  #in case the main Archive is a zip 
                      if [ "$?" -eq "0" ]
                        then
                          rm -r "$f"
                        else
                            echo "Error - cant extract the $f "     
                      fi 
                      decompress_all_complete  # calling to our recursively fun 
                    fi             
                    ;;
                  *gzip*)
                    if [ "$VERBOSE" -eq "0" ]
                     then
                        gzip -d "$f" -kf  # in case the main archive is gz/gzip 
                        let SUCCESS=$?
                        if [ "$SUCCESS" -eq "0" ]  # this is for the call -v folder
                        then
                            let counter++
                            let COUNTER_FILE++
                            echo "Unpacking $f" 
                        fi
                      else  # for -r folder
                        gzip -d "$f" -kf 
                        if [ "$?" -eq "0" ]
                            then
                            rm -r "$f"
                            else
                                echo "Error - cant extract the $f "     
                        fi 
                        decompress_all_complete  # calling to our recursively fun 
                     fi     
                    ;;
                  *bzip2*)
                    if [ "$VERBOSE" -eq "0" ]
                     then
                        bzip2 -d "$f" -kf  
                        let SUCCESS=$?
                        if [ "$SUCCESS" -eq "0" ]
                        then
                            let counter++
                            let COUNTER_FILE++
                            echo "Unpacking $f"
                        fi
                     else   
                      bzip2 -d "$f" -kf 
                      if [ "$?" -eq "0" ]
                        then
                          rm -r "$f"
                        else
                            echo "Error - cant extract the $f "     
                      fi 
                      decompress_all_complete
                     fi      
                    ;; 
                *compress*)
                   if [ "$VERBOSE" -eq "0" ]
                     then 
                        if [ ! "$f" == "*/.Z" ]
                         then
                          mv "$f" "$f.Z"
                        fi

                      uncompress -f "$f" 
                      let SUCCESS=$?   
                      if [ "$SUCCESS" -eq "0" ]
                        then
                        let counter++
                        let COUNTER_FILE++
                        echo "Unpacking $f"
                      fi
                    else
                        if [ ! "$f" == "*/.Z" ]
                         then
                          mv "$f" "$f.Z"
                        fi
                      uncompress -f "$f"
                      if [ "$?" -eq "0" ]
                        then
                          rm -r "$f"
                        else
                            echo "Error - cant extract the $f "     
                      fi 
                      decompress_all_complete
                    fi     
                    ;; 
                   
                 *)
                    let COUNTER_FILE++
                    ;;
                  
                esac
             done
             let "RES = $(( COUNTER_FILE ))"     
            ;;     
        *)
            let SUCCESS=1
            ;;
       
    esac

    if [ "$SUCCESS" -eq "0" ] && [ "$VERBOSE" -eq "0" ]  # we check if the flasg are up or down the make the unpkaing or ingroing 
        then
            if [ "$BASENAME" != "$1" ]
             then
                echo "Unpacking $1" 
             else
                cd .. 
            fi    
    fi

    if [ "$SUCCESS" -eq "1" ] && [ "$VERBOSE" -eq "0" ]  # we check if the flasg are up or down the make the unpkaing or ingroing 
        then
            echo "Ignoring $1"
    
    fi
    shift
 done 






     

           
# this is only printing area      
let RES=$RES-$counter

 if [ ! "$VERBOSE" -eq "0" ] && [ ! "$COUNTER_UNEXTRAT" -eq "0" ] 
    then
       let "RES = $(( COUNTER_UNEXTRAT ))" 
fi

echo "Decompressed $counter archive(s)"

if [ "$RES" -eq "0" ]
 then
	echo "0 (success)"
    exit 0
else
	echo "$RES (failure for $RES file)"
    exit 1
fi



