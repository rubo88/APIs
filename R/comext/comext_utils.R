# Utilidades COMEXT: conversión de JSON (SDMX-like) a data.frame etiquetado
# Copiado desde `scripts/comext_utils.R` para uso local en la carpeta `comext/`.

comext_json_to_labeled_df <- function(doc) {
  vals <- doc$value
  if (is.null(vals) || length(vals) == 0) return(data.frame())

  ids <- doc$id
  sizes <- as.integer(unlist(doc$size))
  dims <- doc$dimension
  n_dims <- length(ids)

  get_strides <- function(sz) {
    n <- length(sz)
    s <- integer(n)
    for (k in seq_len(n)) s[k] <- if (k == n) 1 else prod(sz[(k + 1):n])
    s
  }
  strides <- get_strides(sizes)

  pos_to_code <- function(index_map, pos) {
    codes <- names(index_map)[which(unname(index_map) == pos)]
    if (length(codes) == 0) return(NA_character_)
    codes[[1]]
  }

  value_keys <- as.integer(names(vals))
  value_vals <- as.numeric(unlist(vals, use.names = FALSE))

  make_row <- function(i) {
    idx <- value_keys[[i]]
    r <- idx
    pos <- integer(n_dims)
    for (k in seq_len(n_dims)) { pos[k] <- r %/% strides[k]; r <- r %% strides[k] }

    rec <- list(value = value_vals[[i]])
    for (k in seq_along(ids)) {
      dn <- ids[[k]]
      d <- dims[[dn]]; if (is.null(d)) next
      imap <- unlist(d$category$index)
      lbl  <- d$category$label
      code_k <- pos_to_code(imap, pos[k])
      rec[[dn]] <- code_k
      rec[[paste0(dn, "_label")]] <- if (!is.null(lbl) && !is.null(code_k)) lbl[[code_k]] else NA_character_
    }
    as.data.frame(rec, stringsAsFactors = FALSE)
  }

  rows <- lapply(seq_along(value_keys), make_row)
  df <- do.call(rbind, rows)
  if ("value" %in% names(df)) df$value <- as.numeric(df$value)
  df
}


