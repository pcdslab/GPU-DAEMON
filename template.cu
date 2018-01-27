/*
Copyright (C) Muaaz Gul Awan and Fahad Saeed 
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
*/



#include<iostream>
#include<string>
#include <vector>
#include <time.h>
#include <random>
using namespace std;


__global__ void launchKernel (int *d_mySimpleData);
__device__ int simplifiedOperation(int myData);
__device__ resultSifting(int* myResult);
void PostProcessingFunctions(int *h_myResult);

int main()
{

	/***initializing sample data***
	 2-D array of floats
	 */
	float **myData = new float*[100];
	for(int i = 0; i < 100; i++){
		myData[i] = new float[100];
	}

	srand(time());

	for(int i = 0; i < 100; i++){
		for(int j = 0; j < 100; j++){
			myData[i][j] = rand()%100;
		}
	}

	/**** STEP-1 ***
	 * Simplifying floating point numbers
	 * using a user-defined threshold to
	 * convert them into zeros and ones
	 */

	int **mySimpleData = new float*[100];
	for(int i = 0; i < 100; i++){
		mySimpleData[i] = new float[100];
	}

	float threshold = 50; // can be any suitable number

	for(int i = 0; i < 100; i++){
			for(int j = 0; j < 100; j++){
				mySimpleData[i][j] = myData[i][j]>threshold?1:0;
			}
		}

	// freeing any space
	for(int i = 0; i < 100; i++){
		delete[] myData[i];
	delete[] myData;
	}

	int *d_mySimpleData; // device variable
	int *d_myResult; // variable to store result on device
	int *h_myResult = new int[]; // suitable sized array for result
	cudaMalloc((void**) &d_mySimpleData, 100*100*sizeof(int)); // Assigning memory on device
	cudaMalloc((void**) &d_myResult, 100*100*sizeof(int)); // Assigning memory on device
	cudaMemcpy(d_mySimpleData, mySimpleData, sizeof(int)*100*100, cudaMemcpyHostToDevice); // copying to device via PCIe
	launchKernel<<<100,100>>>(d_mySimpleData); // launch kernel function on device
	cudaMemcpy(h_myResult, 	cudaMemcpy(d_mySimpleData, mySimpleData, sizeof(int)*100*100, cudaMemcpyHostToDevice); //Copy back results via PCIe

	PostProcessingFunctions(h_myResult);

}

/*Step-3
 * fine grained mapping such that
 * each data point is assigned to
 * a unique compute unit, for
 * example of 2-step mapping refer to
 * GPU-ArraySort code
 */

__global__ void launchKernel (int *d_mySimpleData, int *myResult){
	int myID = threadIdx.x + BlockIdx.x*blockDim.x; // for fine grained mappping (STEP-3).

	__shared__ int myShMem[100*100];

	//moving to shared memory (STEP-4)
	myShMem[myID] = d_mySimpleData[myID];

	myResult = simplifiedOperation(myShMem);

	resultSifting (myResult); // in case result is too large, suitable result sifting operation needs to be performed.


}

/*
 * STEP-2
 * simplified operations to be performed on
 * simplified data. User can replace this with
 * desired F_sub.
 */
__device__ int simplifiedOperation(int myData){
	// perform operation on myData in-place.
}
/* STEP-6
 * result sifting operation to filter out interesting
 * results or to compress the large result DS into
 * compact ones. For more example refer to G-MSR code
 */
__device__ resultSifting(int* myResult){
	//filter out result using
	//suitable functions
}

/*
 * STEP-7
 * post processing phase to complete
 * the processing and bring the GPU
 * results in more suitable form
 */
void PostProcessingFunctions(int *h_myResult){
	//perform suitable post processing operations on CPU side
	//for a detailed example refer to G-MSR code where binary
	//spectra are transformed to reduced spectra in post
	//processing phase
}
