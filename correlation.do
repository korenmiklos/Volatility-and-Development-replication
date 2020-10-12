**in  specmeasures21
**get the diagonal
*use specmeasures21
*use specmeasures30, clear
matrix D=vecdiag(Varind)'

**Create the correlation matrix from V
matrix Corr=J(19,19,0)
forval i=1/19 {
  forval j=1/19 {
     matrix Corr[`i',`j']=Varind[`i',`j']/(sqrt(Varind[`i',`i'])*sqrt(Varind[`j',`j']))
  }
}


**Creat the vector of average correlation of the sector
matrix sCorr=J(1,19,0)
matrix avCorr=J(1,19,0)

forval i=1/19 {
       forval j=1/19 {
        matrix sCorr[1,`i']=sCorr[1,`i']+Corr[`j',`i']
      }
matrix avCorr[1,`i']=(sCorr[1,`i']-1)/18
}

**Table2 is the matrix which includes variance and average correlation of the sector

matrix Table2=(D,avCorr')
mat list Table2
