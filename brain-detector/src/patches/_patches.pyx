import cython
cimport numpy as np
import numpy as np

np.import_array()

ctypedef float pixel_t

cdef extern from "patches.h":
    void _extract_patches2D( pixel_t* img,
                        int shape0, int shape1,
                        int* X, int* Y, size_t nb_points,
                        int rx, int ry,
                        pixel_t* patches )
    void _extract_patches3D( pixel_t* img,
                         int shape0, int shape1, int shape2,
                         int* X, int* Y, int* Z, size_t nb_points,
                         int rx, int ry, int rz,
                         pixel_t* patches )
    void _reconstruct_from_patches3D( pixel_t* img,
                                  int shape0, int shape1, int shape2,
                                  int* X, int* Y, int* Z, size_t nb_points,
                                  int rx, int ry, int rz,
                                  pixel_t* patches,
                                  pixel_t* weights )
    void _extract_patches4D( pixel_t* img,
                             int shape0, int shape1, int shape2, int shape3,
                             int* X, int* Y, int* Z, size_t nb_points,
                             int rx, int ry, int rz,
                             pixel_t* patches )
    void _reconstruct_from_patches4D( pixel_t* img,
                                      int shape0, int shape1, int shape2, int shape3,
                                      int* X, int* Y, int* Z, size_t nb_points,
                                      int rx, int ry, int rz,
                                      pixel_t* patches,
                                      pixel_t* weights )    
    void _project_gradients2D( double* grad,
                               int shape0, int shape1,
                               double* projection_matrix,
                               int nb_proj,
                               double* hist )

    void _extract_oriented_patches2D( double* img,
                                  int shape0, int shape1,
                                  double* hist,
                                  double* projection_matrix,
                                  int nb_proj,
                                  int* X, int* Y, size_t nb_points,
                                  int r,
                                  double* patches )
    
@cython.boundscheck(False)
@cython.wraparound(False)
def extract_patches2D( np.ndarray[float, ndim=2, mode="c"] img,
                       np.ndarray[int, ndim=1, mode="c"] X,
                       np.ndarray[int, ndim=1, mode="c"] Y,
                       int rx, int ry ):

    cdef size_t nb_points = X.shape[0]
    cdef np.ndarray[float, ndim=3, mode="c"] patches =  np.zeros( (nb_points,
                                                                   2*ry+1,
                                                                   2*rx+1),
                                                                  dtype='float32')

    _extract_patches2D( <pixel_t*> img.data,
                         img.shape[0],
                         img.shape[1],
                         <int*> X.data,
                         <int*> Y.data,
                         nb_points,
                        rx,  ry,
                        <pixel_t*> patches.data )

    return patches

@cython.boundscheck(False)
@cython.wraparound(False)
def extract_patches3D( np.ndarray[float, ndim=3, mode="c"] img,
                       np.ndarray[int, ndim=1, mode="c"] X,
                       np.ndarray[int, ndim=1, mode="c"] Y,
                       np.ndarray[int, ndim=1, mode="c"] Z,
                       int rx, int ry, int rz ):

    cdef size_t nb_points = X.shape[0]
    cdef np.ndarray[float, ndim=4, mode="c"] patches =  np.zeros( (nb_points,
                                                                   2*rz+1,
                                                                   2*ry+1,
                                                                   2*rx+1),
                                                                  dtype='float32')

    _extract_patches3D( <pixel_t*> img.data,
                         img.shape[0],
                         img.shape[1],
                         img.shape[2],
                         <int*> X.data,
                         <int*> Y.data,
                         <int*> Z.data,
                         nb_points,
                         rx,  ry, rz,
                         <pixel_t*> patches.data )

    return patches

@cython.boundscheck(False)
@cython.wraparound(False)
def reconstruct_from_patches3D( int shape0, int shape1, int shape2,
                                np.ndarray[int, ndim=1, mode="c"] X,
                                np.ndarray[int, ndim=1, mode="c"] Y,
                                np.ndarray[int, ndim=1, mode="c"] Z,
                                np.ndarray[float, ndim=4, mode="c"] patches,
                                int rx, int ry, int rz ):

    cdef size_t nb_points = X.shape[0]
    cdef np.ndarray[float, ndim=3, mode="c"] res =  np.zeros( (shape0,
                                                               shape1,
                                                               shape2),
                                                              dtype='float32')
    cdef np.ndarray[float, ndim=3, mode="c"] weights =  np.zeros( (shape0,
                                                                   shape1,
                                                                   shape2),
                                                                  dtype='float32')

    _reconstruct_from_patches3D( <pixel_t*> res.data,
                                  shape0,
                                  shape1,
                                  shape2,
                                  <int*> X.data,
                                  <int*> Y.data,
                                  <int*> Z.data,
                                  nb_points,
                                  rx,  ry, rz,
                                  <pixel_t*> patches.data,
                                  <pixel_t*> weights.data )

    return res, weights

@cython.boundscheck(False)
@cython.wraparound(False)
def extract_patches4D( np.ndarray[float, ndim=4, mode="c"] img,
                       np.ndarray[int, ndim=1, mode="c"] X,
                       np.ndarray[int, ndim=1, mode="c"] Y,
                       np.ndarray[int, ndim=1, mode="c"] Z,
                       int rx, int ry, int rz ):

    cdef size_t nb_points = X.shape[0]
    cdef int shape0 = img.shape[0]
    cdef np.ndarray[float, ndim=5, mode="c"] patches =  np.zeros( (nb_points,
                                                                   shape0,
                                                                   2*rz+1,
                                                                   2*ry+1,
                                                                   2*rx+1),
                                                                  dtype='float32')

    _extract_patches4D( <pixel_t*> img.data,
                         img.shape[0],
                         img.shape[1],
                         img.shape[2],
                         img.shape[3],
                         <int*> X.data,
                         <int*> Y.data,
                         <int*> Z.data,
                         nb_points,
                         rx,  ry, rz,
                         <pixel_t*> patches.data )

    return patches

@cython.boundscheck(False)
@cython.wraparound(False)
def reconstruct_from_patches4D( int shape0, int shape1, int shape2, int shape3,
                                np.ndarray[int, ndim=1, mode="c"] X,
                                np.ndarray[int, ndim=1, mode="c"] Y,
                                np.ndarray[int, ndim=1, mode="c"] Z,
                                np.ndarray[float, ndim=2, mode="c"] patches,
                                int rx, int ry, int rz ):

    cdef size_t nb_points = X.shape[0]
    cdef np.ndarray[float, ndim=4, mode="c"] res =  np.zeros( (shape0,
                                                               shape1,
                                                               shape2,
                                                               shape3),
                                                              dtype='float32')
    cdef np.ndarray[float, ndim=4, mode="c"] weights =  np.zeros( (shape0,
                                                                   shape1,
                                                                   shape2,
                                                                   shape3),
                                                                  dtype='float32')

    _reconstruct_from_patches4D( <pixel_t*> res.data,
                                  shape0,
                                  shape1,
                                  shape2,
                                  shape3,
                                  <int*> X.data,
                                  <int*> Y.data,
                                  <int*> Z.data,
                                  nb_points,
                                  rx,  ry, rz,
                                  <pixel_t*> patches.data,
                                  <pixel_t*> weights.data )

    return res, weights


@cython.boundscheck(False)
@cython.wraparound(False)
def project_gradients2D( np.ndarray[double, ndim=3, mode="c"] grad,
                         np.ndarray[double, ndim=2, mode="c"] projection_matrix ):
    
    cdef np.ndarray[double, ndim=3, mode="c"] hist = np.zeros( (grad.shape[0],
                                                                grad.shape[1],
                                                                projection_matrix.shape[0]),
                                                                    dtype='float64')

    _project_gradients2D( <double*> grad.data,
                          grad.shape[0],
                          grad.shape[1],
                          <double*> projection_matrix.data,
                          projection_matrix.shape[0],
                          <double*> hist.data )

    return hist

@cython.boundscheck(False)
@cython.wraparound(False)
def extract_oriented_patches2D( np.ndarray[double, ndim=2, mode="c"] img,
                                np.ndarray[double, ndim=3, mode="c"] hist,
                                np.ndarray[double, ndim=2, mode="c"] projection_matrix,
                                np.ndarray[int, ndim=1, mode="c"] X,
                                np.ndarray[int, ndim=1, mode="c"] Y,
                                int r ):

    cdef size_t nb_points = X.shape[0]

    cdef np.ndarray[double, ndim=3, mode="c"] patches = np.zeros( (nb_points,
                                                                   2*r+1,
                                                                   2*r+1),
                                                                  dtype='float64')
    
    _extract_oriented_patches2D( <double*> img.data,
                                  img.shape[0],
                                  img.shape[1],
                                  <double*> hist.data,
                                  <double*> projection_matrix.data,
                                  projection_matrix.shape[0],
                                  <int*> X.data,
                                  <int*> Y.data,
                                  nb_points,
                                  r,
                                  <double*> patches.data )

    return patches
