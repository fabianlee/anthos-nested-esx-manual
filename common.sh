
# terraform variables files
echo BIN_DIR is $BIN_DIR

# pulls terraform variable values out of file
function getTFVal() {
  tfvarsfile=$1
  thevar=$2
  grep $thevar $tfvarsfile | awk '{print $3}' | sed 's/"//g'
}

