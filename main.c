#include <stdio.h>
#include <stdlib.h>

#define N 4 //size of domain and range blocks
#define R 288 // height of the original image
#define C 352 // width of the original image

short rangeImage[R][C], domainImage[R/2][C/2];

void printBlock(short array[N][N])
{
    short i,j;

    for(i=0; i<N; i++)
    {
        for(j=0; j<N; j++)
        {
            printf("%d ", array[i][j]);
        }
        printf("\n");
    }
}

void printImage(short array[R][C])
{
    short i,j;

    for(i=0; i<R; i++)
    {
        for(j=0; j<C; j++)
        {
            printf("%d ", array[i][j]);
        }
        printf("\n");
    }
}

//Read the original image
void readImage()
{
    short i,j;
    FILE *frame_c;
    if((frame_c=fopen("foreman_cif_0_yuv420.yuv","rb"))==NULL)
    {
    printf("current frame doesn't exist\n");
    exit(-1);
    }

    for(i=0;i<R;i++)
    {
        for(j=0;j<C;j++)
        {
            rangeImage[i][j]=fgetc(frame_c);
        }
    }
}

//Write image to a file
void write_image(int image[R][C])
 {
    FILE *infile;
    int i,j;
    if((infile=fopen("finalImage.y","w+"))==NULL)
    {
        exit(-1);
    }
    for(i=0;i<R;i++)
    {
        for(j=0;j<C;j++)
        {
            fputc(image[i][j],infile);
        }
    }

    fclose(infile);
}

//Finds the mean square error between too N-by-N blocks
double meanSquareError(short range[N][N], short domain[N][N])
{
    short i,j;
    short temp;
    double msevalue=0;

    for (i=0;i<N;i++)
    {
        for (j=0;j<N;j++)
        {
            temp=range[i][j]-domain[i][j];
            msevalue=msevalue+temp*temp;
        }
    }

    return msevalue / (N*N);
}

//Rotates a N-by-N block by 90 degrees to the right
//used for all the rotations
void rNinety(short block[N][N])
{
    short i,j;
    short temp[N][N];

    for (i=0;i<N;i++)
    {
        for (j=0;j<N;j++)
        {
            temp[i][j]= block[N-1-j][i];
        }
    }
    for (i=0;i<N;i++)
    {
        for (j=0;j<N;j++)
        {
            block[i][j]=temp[i][j];
        }
    }


}

//Flips a N-by-N block upside down
void flipSimple(short block[N][N])
{
    short i,j;
    short temp[N][N];

    for(i=0; i<N; i++){
        for(j=0; j<N; j++){
            temp[i][j] = block[N-1-i][j];
        }
    }

     for(i=0; i<N; i++){
        for(j=0; j<N; j++){
            block[i][j] = temp[i][j];
        }
    }

}

//Finds the index of domain block that was closest to the corresponding range block
//mseMin holds the mean square errors between a range block and all the possible domain blocks
short minMSE(double mseMin[R*C/8])
{
    double m = mseMin[0];
    short i, ind=2;

    for (i=1; i<R*C/8; i++)
    {
        if (mseMin[i] < m && mseMin[i] > 1)
        {
            m = mseMin[i];
            ind = i;
        }
    }
    return ind;

}


//Main function
int main()
{

    short domainBlock[N][N], rangeBlock[N][N];

    short i,j, ki=0, kj=0, li, lj, t; //All the integers that are needed for the loops
    short blockCounter, bestBlockInd;
    int rangeCounter;
    double mseMin[R*C/8], newMse;
    short minTrans[R*C/8];
    short bestTrans[R*C/16]; //The transformations that are going to be applied to the domain blocks
    short bestTransBlock[R*C/16]; //The indexes of the domain blocks to the corresponding range blocks

    readImage();

    //Down sample the domain image
    for(i=0; i<R; i+=2){
        for(j=0; j<C; j+=2){
            domainImage[ki][kj] = rangeImage[i][j];
            kj++;
        }
        kj=0;
        ki++;
    }

    //Operations to calculate the bestTransBlock and bestTrans
    rangeCounter = 0;
    for(i=0; i<R; i+=4)
    {
        for(j=0; j<C; j+=4)
        {
            for(ki=0; ki<N; ki++)
            {
                for(kj=0; kj<N; kj++)
                {
                    rangeBlock[ki][kj] = rangeImage[ki+i][kj+j]; //Fill the range block that is going to be checked
                }
            }
            //Access all the domain blocks, transform them and find the best match for the range block
            blockCounter=0;
            for(li=0; li<R/2; li+=2)
            {
                for(lj=0; lj<C/2; lj+=2)
                {
                    for(ki=0; ki<N; ki++)
                    {
                        for(kj=0; kj<N; kj++)
                        {
                            domainBlock[ki][kj] = domainImage[ki + li][kj + lj];
                        }
                    }
                    //Start applying all the possible transformations the find the best one
                    //Case 1: No transformation
                    mseMin[blockCounter] = meanSquareError(domainBlock, rangeBlock);
                    minTrans[blockCounter] = 1;
                    //Case 2,3,4: Rotate 90, 180 and -90 degrees
                    for(t=0; t<3; t++)
                    {
                        rNinety(domainBlock);
                        newMse = meanSquareError(domainBlock, rangeBlock);
                        if (newMse < mseMin[blockCounter])
                        {
                            mseMin[blockCounter] = newMse;
                            minTrans[blockCounter] = t+1;
                        }
                    }
                    //Case 5: Flip upside down
                    flipSimple(domainBlock);
                    newMse = meanSquareError(domainBlock, rangeBlock);
                    if (newMse < mseMin[blockCounter])
                    {
                        mseMin[blockCounter] = newMse;
                        minTrans[blockCounter] = 5;
                    }
                    //Case 6,7,8: Rotate 90, 180 and -90 degrees while flipped
                    for(t=0; t<3; t++)
                    {
                        rNinety(domainBlock);
                        newMse = meanSquareError(domainBlock, rangeBlock);
                        if (newMse < mseMin[blockCounter])
                        {
                            mseMin[blockCounter] = newMse;
                            minTrans[blockCounter] = t+6;
                        }
                    }
                blockCounter++;
                }
            }
            //Find the best transformation and the corresponding domain block
            bestBlockInd = minMSE(mseMin);
            bestTrans[rangeCounter] = minTrans[bestBlockInd];
            bestTransBlock[rangeCounter] = bestBlockInd;
            rangeCounter++;
        }
    }


    return 0;
}
