#include <stdio.h>
#include <stdlib.h>
#include <math.h>


//takes a 1D array for window and frame, fRow and fCol are the dimensions of the frame 2D array, wCol and wRow are the dimensions of the window, and fRowIndex and fColIndex
//are the indices of the element in the frame that the calculation is based on
int sad(int* window, int* frame, int fRow, int fCol, int wCol, int wRow, int fRowIndex, int fColIndex){
    int sum;
    int window1DIndex;
    int frame1DIndex;
    for(int i = 0; i < fCol; i++){
        for(int j = 0; j < fRow; j++){
            window1DIndex = convert2DTo1DIndex(wCol, i, j); //converts the index for the window into 2D
            frame1DIndex = convert2DTo1DIndex(fCol, i + fRowIndex, j + fColIndex); //converts the index for the current element of the frame
            sum += abs(window[window1DIndex] - frame[frame1DIndex]);
    }     
    }
    return sum;
}


//i = col index, j = row index


int convert2DTo1DIndex(int col, int i, int j){
    int row1D = col * j;
    int index1D = row1D + i;
    return index1D; 
}

void diagSearch(int col,int  row){
    int i = 0;
    int j = 0;
    int polarity = 1;
    int rowEvenOrOdd = 0;
    int colEvenOrOdd = 0;
    if(row % 2 == 1)
        rowEvenOrOdd = 1;
    if(col % 2 == 0)
        colEvenOrOdd = 1;
    
    while(i < col && j < row){
        printf( "(%d, %d) ", i, j);
        
        if( j == row - 1 && i % 2 == rowEvenOrOdd){
            i += 1;
            polarity *= -1;
        }
        else if(i == col - 1 && j % 2 == colEvenOrOdd){
            j += 1;
            polarity *= -1;
        }
        else if(j == 0 && i % 2 == 0){
            i += 1;
            polarity *= -1;
        }
        else if(i == 0 && j % 2 == 1){
            j += 1;
            polarity *= -1;
        }
        
        
        else{
            i += 1 * polarity;
            j += -1 * polarity;

        }
    
    }
    
    
}


int main(void){
    diagSearch(8, 8);

}