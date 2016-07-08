{
if(NR==1) for(i=1;i<=NF;i++) { if($i==colname) { colnum=i;break} }
else print $colnum
}
