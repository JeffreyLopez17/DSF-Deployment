clear

#Read arguments
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

echo "=============================="
echo "=== DSF Package Deployment ===" 
echo "=============================="

# Check if BASEPATH argument was used
if ! [ $BASEPATH ]
then 
 basePath="./"
else
 basePath=$BASEPATH
fi

# Check if HOSTSTRING argument was used
if ! [ $HOSTSTRING ]
then 
 hostString="host.docker.internal:9089"
else
 hostString=$HOSTSTRING
fi

echo "Checking for packages in path $basePath"

url="http://${hostString}/dsf-iris/api/v1.0.0/meta/dsfpackages/deploy?retry=false"

if [ -n "$(ls -A ${basePath}*.zip 2>/dev/null)" ]
then
	search_dir=`ls ${basePath}*.zip`
	fileCount=`ls ${basePath}*.zip | wc -l`
	dateTime=$(date +'%Y-%m-%d_%H-%M-%S')
	echo "Files found: " $fileCount

	if ! [ -d "${basePath}Processed" ]
	then
		mkdir "${basePath}/Processed"
	fi
	mkdir "${basePath}/Processed/${dateTime}"

	# Deploy all packages found
	for entry in $search_dir
	do
		filename=$(basename ${entry})
		echo "Deploying package $filename"
		curl -X POST -L -F "package=@$entry;type=application/zip" $url
		mv $entry $basePath/Processed/$dateTime/$filename
	done
else
	echo "No packages found!"
fi
