

#' Generate Nested 2D Training Data.
#' @description This function generates 2D training data as specified in "Beispiel 10.23" in reference "Richter19". The result will be an inner clusters surrounded by a ring of points, the outer cluster. This data is especially useful to test spectral clustering.
#' @param n integer; the number of vectors in the returned training data.
#' @return returns a matrix with two rows and \code{n} columns; each column is a training vector.
#' @export
#'
#' @examples
#' generate_nested_2d_training_data(10)
generate_nested_2d_training_data <- function (n) {
  stopifnot("n has to be numeric" = is.numeric(n))
  n <- as.integer(n)
  stopifnot("n has to be a non-negative number" = n >= 0);

  innerOrOuter <- c();
  # #' Generate a Single Training Vector
  # #' @description This function generates a single training vector as specified in "Beispiel 10.23" in reference "Richter19"
  # #' @return returns a single training vector
  # #' @references Richter, S. (2019). Statistisches und maschinelles Lernen. Springer Spektrum.
  # #' @example generate_training_vector()
  generate_training_vector <- function () {
    R <- function(z) {
      Delta <- stats::runif(1,-0.1, 0.1)
      if (z == 1L) {
        innerOrOuter <<- c(innerOrOuter, 1);
        return(Delta + .3)
      } else {
        stopifnot("z should be either 1 or 2" = z == 2L)
        innerOrOuter <<- c(innerOrOuter, 2);
        return(Delta + 1)
      }
    }

    Z <- sample.int(2, size = 1)
    U <- stats::runif(1, 0, 2 * pi)
    X_1 <- R(Z) * c(cos(U), sin(U))

    return(X_1)
  }

  data <- replicate(n, generate_training_vector());
  attr(data, "innerOrOuter") <- innerOrOuter;

  return(data);
}

#' Generate a Cluster of Two Dimensional Vectors
#' @description Generates a cluster of two dimensional vectors. The number of vectors and the center of the cluster may be specified via the function's arguments.
#'
#' @param n integer; number of vectors that comprise the returned cluster
#' @param center vector; vector of two elements specifying thw x,y coordinates of the center point
#'
#' @return Returns a matrix with two rows and n columns containing the generated cluster of two dimensional vectors as column-vectors.
#' @export
#'
#' @examples
#' aCluster <- generate_2d_cluster(100);
#' anotherCluster <- generate_2d_cluster(200, center=c(3,2));
generate_2d_cluster <- function (n, center=c(0,0)) {
  stopifnot("n has to be numeric" = is.numeric(n))
  n <- as.integer(n)
  stopifnot("n has to be a non-negative number" = n >= 0);

  generate_vector <- function (offsetX=0, offsetY=0) {
    U <- stats::runif(1, 0, 2 * pi)
    scale <- stats::rnorm(1, .5, .5)
    X_1 <- scale * c(cos(U), sin(U))

    X_1[1] <- X_1[1] + offsetX
    X_1[2] <- X_1[2] + offsetY

    return(X_1)
  }
  replicate(n, generate_vector(center[1], center[2]));
}

#' Plot Clustered 2D Data
#'
#' @param data matrix; columns are vectors. Has to have the \code{"cluster"} attribute set.
#' @param point_size numeric; size of the points
#' @param show_noise logical; toggle plotting of noise
#' @param show_legend logical; toggle legend display
#' @param hide_axis_text logical; toggle axis text
#' @param connect_to_predecessor logical; toggle lines connecting points to their predecessor; this only works with data produced by the OPTICS algorithmdevto
#'
#' @export
#'
#' @examples
#' data <- matrix(c(1,1,2,1), nrow=2);
#' attr(data, "cluster") <- c(1,2);
#' plot_clustered_2d_data(data);
plot_clustered_2d_data <- function(data, point_size=.75, show_noise=TRUE, show_legend=FALSE, hide_axis_text=FALSE, connect_to_predecessor=FALSE) {
  stopifnot("The passed data needs to have the \"cluster\" set" =  "cluster" %in% names(attributes(data)));
  if (nrow(data) > 2) {
    warning("The passed data has more than two dimensions. Only the first two dimensions are used for plotting!");
  }

  stopifnot("point_size has to be numeric" = is.numeric(point_size))
  stopifnot("point_size has to be positive" = point_size > 0)

  get_color_generator <- function () {
    # "Dark2" color palette generated by the RColorBrewer package.
    palette <- c("#1B9E77", "#D95F02", "#7570B3", "#E7298A", "#66A61E", "#E6AB02", "#A6761D", "#666666")
    cnt <- 0

    function () {
      cnt <<- cnt + 1;
      palette[(cnt %% 8) + 1];
    }
  }

  numVectors <- ncol(data);
  clusters <- unique(attr(data, "cluster"));
  clusters <- clusters[!(clusters < 0)]
  numClusters <- length(clusters);

  col_gen <- get_color_generator();

  n <- ncol(data);

  x <- data[1,];
  y <- data[2,];

  if (hide_axis_text) {
    plot(x, y, xlab="x", ylab="y", pch=1, cex=point_size, cex.axis=.75, xaxt='n', yaxt='n');
  } else {
    plot(x, y, xlab="x", ylab="y", pch=1, cex=point_size, cex.axis=.75);
  }

  legendlabels <- c()
  legendcolors <- c()

  if (show_noise) {
    noiseIdx <- attr(data, "cluster") < 0;
    graphics::points(data[1, noiseIdx], data[2, noiseIdx], col="black", pch=19, cex=point_size);

    legendlabels <- c("Noise")
    legendcolors <- c("black")
  }

  if (connect_to_predecessor) {
    if (sum(c("predecessor", "ordering") %in% names(attributes(data))) == 2)  {
      UNDEFINED <- Inf;
      predecessor <- attr(data,"predecessor");
      order <-attr(data, "ordering");
      for (i in 1:n) {
        b <- order[i]
        a <- predecessor[b]
        if (a == UNDEFINED) next;
        graphics::segments(x[a], y[a], x[b], y[b], lwd=1, col=grDevices::rgb(0,0,0,.75))
      }
    } else {
      warning("connect_to_predecessor is set, but the given data is not the result of a call to OPTICS. Skipping this option.");
    }
  }

  for (i in clusters) {
    clusterIdx <- attr(data, "cluster") == i;
    clusterX <- x[clusterIdx];
    clusterY <- y[clusterIdx];

    cur_col <- col_gen();

    graphics::points(clusterX, clusterY, col=cur_col, pch=19, cex=point_size);

    legendlabels <- c(legendlabels, paste("Cluster", i));
    legendcolors <- c(legendcolors, cur_col);
  }

  if (show_legend) {
    graphics::legend("topright", legend=legendlabels, fill = legendcolors, col=legendcolors, cex=1);
  }
}

