## PROJECT:  HFR Data Quality Assessment
## AUTHOR:   B.Kagniniwa | USAID
## LICENSE:  MIT
## PURPOSE:  PARSE JSON Data
## Date:     2020-06-30

# LIBRARIES

library(tidyverse)
library(jsonlite)
library(sf)
library(gisr)
library(glitr)
library(scales)
library(patchwork)
library(Wavelength)
library(glamr)
library(here)

## GLOBAL ------------------------------------

## Project data
dir_data <- "Data"
dir_dataout <- "Dataout"

## Image Graphics
dir_images <- "./Images"
dir_graphics <- "./Graphics"

# DATIM Access
user <- ""
key <- ""


# FUNCTIONS -------------------------------------------------------------------------

#' Get OU uid
#'
#' @param country
#' @param username Datim Account username
#' @param password Datim Account Key
#'
get_ouuid <- function(country, username, password) {

    cntry = toupper({{country}})
    user <- {{username}}
    pass <- {{password}}

    ous <- Wavelength::identify_ouuids(username = user, password = pass)

    if (is.data.frame(ous) & "displayName" %in% names(ous) & cntry %in% toupper(ous$displayName)) {
        ous <- ous %>%
            dplyr::filter(toupper(displayName) == cntry)
    }
    else {
        cat("\nInvalid PEPFAR OU or Country Name:\n",
            Wavelength::paint_red(cntry),
            "\n")

        return(NULL)
    }

    return(ous %>% pull(id) %>% first())
}


#' Extract location data
#'
#' @param country PEPFAR Operating Unit or Regional Countries
#' @param username Datim Account Username
#' @param password Datim Account Key
#'
extract_locations <- function(country, username, password) {

    baseurl = "https://final.datim.org/"

    cntry <- {{country}}
    user <- {{username}}
    pass <- {{password}}

    # Get country uid
    ouuid <- get_ouuid(cntry, username = user, password = pass)

    # Get country org levels
    ou_levels <- Wavelength::identify_levels(
            ou = cntry,
            username = user,
            password = pass
        ) %>%
        dplyr::relocate(dplyr::last_col(), .after = name4) %>%
        tidyr::gather(key = "label", value = "level", -c(1:5))

    # Query OU Location data
    df <- baseurl %>%
        paste0("api/organisationUnits?filter=path:like:", ouuid,
               "&fields=id,name,path,level,geometry&paging=false&format=json") %>%
        httr::GET(httr::authenticate(user, pass)) %>%
        httr::content("text") %>%
        jsonlite::fromJSON(flatten = T) %>%
        purrr::pluck("organisationUnits") %>%
        tibble::as_tibble() %>%
        dplyr::rename(
            geom_type = geometry.type,          # NA or Geometry Type Value
            coordinates = geometry.coordinates  # NA or list of 2 or more
        ) %>%
        dplyr::mutate(
            gid = row_number(),  # Geom ID
            nodes = as.integer(lengths(coordinates) / 2), # Geom is a pair of lon / lat
            nested = lapply(coordinates, function(x) return(is.list(x))),
            geom_type = ifelse(nested == TRUE & geom_type != "MultiPolygon", 'MultiPolygon', geom_type)
        ) %>%
        dplyr::relocate(coordinates, .after = last_col())

    # Flag org categories
    df <- df %>%
        left_join(ou_levels, by = "level") %>%
        dplyr::select(operatingunit = name3, country_name, label, level:coordinates) %>%
        dplyr::mutate(
            label = ifelse(is.na(label) & level == 4, "SNU1", label),
            geom_type = case_when(
                is.na(geom_type) & label == "facility" ~ "Point",
                is.na(geom_type) & label != "facility" ~ "Polygon",
                TRUE ~ geom_type
            ),
            geom_type = ifelse(label != "facility" & nested == TRUE, "MultiPolygon", geom_type)
        )

    return(df)
}


#' Extract facility sites
#'
#' @param .data Datim organisation units data frame
#' @param targets Data Frame of MER Results / Targets
#'
extract_facilities <- function(.data, targets = NULL) {

    .data <- .data %>%
        dplyr::filter(label == "facility") %>%
        tidyr::unnest_wider(data = ., col = "coordinates") %>%
        janitor::clean_names() %>%
        dplyr::rename(longitude = "x1", latitude = "x2")

    if ( !is.null(targets) ) {

        .data <- .data %>%
            dplyr::left_join(
                targets %>%
                    dplyr::filter(!is.na(mer_results)) %>%
                    dplyr::distinct(orgunit, orgunituid),
                by = c("id" = "orgunituid")
            ) %>%
            dplyr::filter(!is.na(orgunit)) %>%
            dplyr::select(-orgunit)
    }

    return(.data)
}


#' Explore facility locations
#'
#' @param .data Datim organisation units data frame
#' @param cntry Country name
#' @param terr_path Path to terrain raster dataset
#'
explore_facilities <- function(.data, cntry, terr_path = NULL) {

    # Make sure to use rnaturalearth version of the name
    country <- dplyr::case_when(
        cntry == "Cote d'Ivoire" ~ "Ivory Coast",
        cntry == "Eswatini" ~ "Swaziland",
        cntry == "United Republic of Tanzania" ~ "Tanzania",
        TRUE ~ {{cntry}}
    )

    # Count non valid lat/lon
    na_sites <- .data %>%
        dplyr::filter(is.na(longitude) | is.na(latitude)) %>%
        nrow()

    if (na_sites > 0) {
        cat(paste0("\nThere are missing lat/lon: ", Wavelength::paint_red(na_sites), "\n"))
    }

    # Get a basemap: terrain or country boundaries
    if (!is.null(terr_path)) {

        m <- gisr::terrain_map(countries = country, terr_path = {{terr_path}}, mask = TRUE)
    }
    else {

        m <- ggplot2::ggplot() +
          ggplot2::geom_sf(data = gisr::get_admin0(countries = country), fill = NA)
    }

    # Overlay facility data, if data exists
    if ( nrow(.data) > 0 ) {

        m <-  m +
          ggplot2::geom_sf(
                data = .data %>%
                    dplyr::filter(!is.na(longitude) | !is.na(latitude)) %>%
                    sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326),
                shape = 21, size = 3, colour = "white", fill = glitr::grey60k, stroke = .5, alpha = 2/3
            ) +
            ggplot2::coord_sf() +
            ggplot2::theme_void()
    }
    else {

        m <-  m +
            ggplot2::coord_sf() +
            ggplot2::theme_void()
    }

    print(m)

    return(m)
}



#' Assess facility geo-location reporting levels
#'
#' @param .data Datim organisation units data frame
#' @export
#' @examples
#'
assess_facilities <- function(.data) {

    if ( !is.data.frame(.data) | nrow(.data) == 0 ) {
      return(NULL)
    }

    p <- .data %>%
        dplyr::mutate(
          valid_geom = ifelse(is.na(latitude) | is.na(longitude), "Missing", "Available"),
          valid_geom = as.factor(valid_geom)) %>%
        dplyr::group_by(valid_geom) %>%
        dplyr::tally(x = .) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(
            p = round(n / sum(n) * 100),
            t = 100
        ) %>%
        ggplot2::ggplot(aes(valid_geom, p, fill = valid_geom, label = p)) +
        ggplot2::geom_hline(yintercept = 0, color = grey20k) +
        ggplot2::geom_hline(yintercept = 25, color = grey20k) +
        ggplot2::geom_hline(yintercept = 50, color = grey20k) +
        ggplot2::geom_hline(yintercept = 75, color = grey20k) +
        ggplot2::geom_hline(yintercept = 100, color = grey20k) +
        ggplot2::geom_col(aes(y = t), fill = grey10k) +
        ggplot2::geom_col(position = position_dodge(), show.legend = FALSE) +
        ggplot2::geom_label(aes(label = format(n, big.mark = ",", scientific = FALSE)), color = "white", show.legend = FALSE) +
        ggplot2::scale_y_continuous(labels = function(n){paste0(n, "%")}) +
        ggplot2::scale_fill_manual(values = c("#66c2a5", "#fc8d62")) +
        ggplot2::labs(title = "", x = "", y = "") +
        glitr::si_style_nolines()

    return(p)
}


#' Unpack a list of lon/lat into a polygon of type sfg
#'
#' @param .data organization units data frame
#'
unpack_coordinates <- function(.data) {

    if (!'coordinates' %in% names(.data) | nrow(.data) == 0) {
        cat(paste0("\n", Wavelength::paint_red("Invalid data frame used to unpack coordinates"), "\n"))
        stop("Unable to unpack coordinates")
    }

    cols <- length(names(.data)) - 1

    df <- .data %>%
        pull(gid) %>%
        map_dfr(function(id) {

            d <- .data %>% filter(gid == id)

            d %>%
                unnest_wider(col = "coordinates") %>%
                janitor::clean_names() %>%
                gather("coords_pos", "lonlat", -c(1:length(d) - 1) ) %>%
                mutate(
                    coords_pos = as.integer(gsub(pattern = "\\D", "", coords_pos)),
                    coords_type = case_when(
                        coords_pos <= nodes ~ "longitude",
                        TRUE ~ "latitude"
                    ),
                    coords_pos = case_when(
                        coords_pos > nodes ~ coords_pos - nodes,
                        TRUE ~ coords_pos
                    )
                ) %>%
                spread(coords_type, lonlat)
        })

    return(df)
}


#' Extract polygons
#'
#' @param .data Datim organisation units data frame
#' @export
#' @examples
#'
extract_polygons <- function(.data) {

    .data %>%
        filter(geom_type == "Polygon") %>%
        select(-geom_type) %>%
        pull(id) %>%
        map_dfr(unpack_coordinates, .data)
}


#' Extract PSNUs
#'
#' @param .data Datim organisation units data frame
#' @export
#' @examples
#' \dontrun{
#'
extract_psnu <- function(.data) {

    geoms <- .data %>%
        distinct(geom_type)

    na_psnu <- .data %>%
        filter(label == 'prioritization', nodes == 0) %>%
        nrow()

    if (na_psnu > 0) {
        cat(paste0("\nThere are missing geometries: ", Wavelength::paint_red(na_psnu), "\n"))
    }

    .data <- .data %>%
        filter(label == 'prioritization', nodes > 0)

    if ("MultiPolygon" %in%  geoms) {

        plg <- .data %>%
            filter(geom_type == "Polygon")

        mplg <- .data %>%
            filter(geom_type == "MultiPolygon") %>%
            unnest_longer(col = coordinates) %>%
            mutate(
                geom_type = "Polygon",
                gid2 = row_number(),
                nodes = as.integer(lengths(coordinates) / 2)
            )

        .data <- plg %>%
            bind_rows(mplg) %>%
            mutate(gid = row_number())
    }


    .data %>%
        pull(id) %>%
        map_dfr(function(id) {
            .data %>%
                filter(id == id) %>%
                unpack_coordinates()
        })
}


#' Convert list of lon/lat into a polygon sfg
#'
#' @param .data
#'
build_polygons <- function(.data) {

    .data %>%
        filter(nodes > 0) %>%
        st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
        group_by(gid) %>%
        summarise(geometry = st_combine(geometry)) %>%
        ungroup() %>%
        st_cast("POLYGON")
}


#' Explore communities, orgunit areas
#'
#' @param .data Datim organisation units data frame
#'
explore_polygons <- function(.data) {

    .data %>%
        ggplot() +
        geom_sf() +
        coord_sf() +
        theme_void()
}


#' Convert coordinates to polylines
#'
#' @param coords List of lat/lon pairs
#'
to_linestring <- function(coords) {

    geom <- st_linestring(matrix(unlist(coords), ncol = 2))

    return(geom)
}


#' Convert coordinates to polygons
#'
#' @param coords List of lat/lon pairs
#'
to_polygon <- function(coords) {

    geom <- st_polygon(list(matrix(unlist(coords), ncol = 2)))

    return(geom)
}


#' Report locations data completeness
#'
#' @param cntry Country name
#' @param targets Latest MER Results / Targets
#' @param user Datim account username
#' @param pass Datim account password (glamr::mypwd is recommended)
#' @param terr_path Path to terrain raster data
#' @param output_folder Output folder
#'
generate_sites_report <- function(cntry = "Democratic Republic of the Congo",
                                          targets, user, pass,
                                          terr_path = NULL, output_folder = NULL) {

    # Extract Site Location Data
    sites <- extract_locations(country = {{cntry}}, username = {{user}}, password = {{pass}}) %>%
        extract_facilities(targets = {{targets}})

    # Check data
    if (is.null(sites) | nrow(sites) == 0) {

        cat("\n", cat(Wavelength::paint_red({{cntry}})), "\n")
    }

    # Map sites locations
    viz_map <- NULL

    if ( !is.null(terr_path) ) {
        viz_map <- sites %>%
            explore_facilities(cntry = {{cntry}}, terr_path = {{terr_path}})
    }
    else {
        viz_map <- sites %>%
            explore_facilities(cntry = {{cntry}})
    }

    # Plot completeness
    viz_bar <- sites %>%
        assess_facilities()

    # Combine plots
    viz <- (viz_map + viz_bar) +
        patchwork::plot_layout(widths = c(2,1)) +
        patchwork::plot_annotation(
            title = toupper({{cntry}}),
            subtitle = "Facilities location data availability",
            pathwork::theme = ggplot2::theme(
                plot.title = element_text(hjust = .5),
                plot.subtitle = element_text(hjust = .5)
            )
        )

    print(viz)

    if ( !is.null(output_folder) ) {
        ggplot2::ggsave(
            filename = paste0({{output_folder}}, "/", {{cntry}}, " - Sites location data availability.png"),
            scale = 1.2, dpi = 310, width = 10, height = 7, units = "in")
    }
}


#' Extract table from JSON
#'
extract_table <- function(username,
                          password,
                          ou_code = "HTI",
                          ou_level = 7,
                          baseurl = "https://datim.org/"){

    package_check("curl")
    package_check("httr")
    package_check("jsonlite")

    stopifnot(curl::has_internet())

    #compile url
    url <- paste0(baseurl,
                  "api/sqlViews/DataExchOUs/data.json?var=OU:", ou_code,
                  "&filter=orgunit_level:eq:", ou_level,
                  "&paging=false")

    #pull data from DATIM
    df <- url %>%
      httr::GET(httr::authenticate(username,password)) %>%
      httr::content("text") %>%
      jsonlite::fromJSON()

    headers <- df$listGrid$headers$column

    df <- df$listGrid$rows %>%
      as.matrix() %>%
      as_tibble()

    colnames(df) <- headers

    return(df)
}

df <- extract_table(user, mypwd(key))

df %>% glimpse()

#df %>% View()




# DATA ------------------------------------------------------------------------------

    ## MER Targets
    mer_targets <- get_mer_targets()

    mer_targets %>% glimpse()

    #cntry <- "Democratic Republic of the Congo"
    # cntry <- "Malawi"
    # cntry <- "South Africa"
    # cntry <- "Togo"
    #cntry <- "Angola"
    cntry <- "Nigeria"

    # A bit slow
    #mer_targets_ken <- Wavelength::pull_mer(ou_name = cntry, username = user, password = glamr::mypwd(key))

    df <- extract_locations(cntry, username = user, password = glamr::mypwd(key))

    df %>% glimpse()

    #df %>% head() #%>% View()

    df %>%
      mutate(parent = lengths(str_split(path, "/"))) %>% glimpse()
      separate(path, sep = "/")

    df %>%
        distinct(label, level) %>%
        arrange(level)


    sites <- df %>%
        extract_facilities(targets = mer_targets)

    sites %>% glimpse()
    sites %>% View()

    sites %>%
        explore_facilities(cntry = cntry)

    sites %>%
      explore_facilities(cntry = cntry, terr_path = dir_terr)

    v_map <- sites %>%
        explore_facilities(cntry = cntry, terr_path = dir_terr)

    v_bar <- sites %>%
        assess_facilities()

    (v_map + v_bar) +
        plot_layout(widths = c(2,1)) +
        plot_annotation(
            title = toupper(cntry),
            subtitle = "Facilities location data availability",
            theme = theme(
                plot.title = element_text(hjust = .5),
                plot.subtitle = element_text(hjust = .5)
            )
        )

    generate_sites_report(cntry = "Nigeria",
                              targets = mer_targets,
                              user = user,
                              pass = glamr::mypwd(key),
                              terr_path = dir_terr,
                              output_folder = "./Graphics")



    ous <- Wavelength::identify_ouuids(username = user, password = glamr::mypwd(key))


    ous %>%
        filter(is.na(regional), !str_detect(displayName, "Region")) %>%
        pull(displayName) %>%
        map(.x, .f = ~generate_sites_report(cntry = .x,
                                               user = user,
                                               pass = glamr::mypwd(key),
                                               targets = mer_targets,
                                               terr_path = dir_terr,
                                               output_folder = dir_graphics))

    c("Angola","Botswana",
     "Burundi","Cameroon")

    #c("Cote d'Ivoire")

    c("Democratic Republic of the Congo",
     "Dominican Republic")

    #c("Eswatini")

    c("Ethiopia", "Haiti",
      "Kenya", "Lesotho",
      "Malawi", "Mozambique",
      "Namibia","Nigeria",
      "Rwanda", "South Africa")

    #c("South Sudan")

    c("Tanzania")

    c("Uganda", "Ukraine",
      "Vietnam", "Zambia",
      "Zimbabwe")

    c("Nigeria", "South Africa", "Uganda") %>%
        map(.x, .f = ~report_locations_completeness(cntry = .x,
                                                user = user,
                                                pass = glamr::mypwd(key),
                                                targets = mer_targets,
                                                terr_path = dir_terr,
                                                output_folder = dir_graphics))











    # PSNUs

    df %>% glimpse()

    df %>%
        pull(geom_type) %>%
        unique()

    df %>%
        count(geom_type)

    df %>%
        mutate(valid = ifelse(nodes > 0, TRUE, FALSE)) %>%
        count(geom_type, valid) %>%
        group_by(geom_type) %>%
        mutate(p = round(n / sum(n) * 100))

    df %>%
        filter(geom_type != "Point", nodes > 0) %>%
        distinct(geom_type, nodes) %>%
        arrange(desc(nodes))


    ## Works only for simple Polygons
    df %>%
        filter(label == 'prioritization', nodes > 0) %>%
        filter(geom_type == 'Polygon') %>% #glimpse()
        #extract_psnu() %>%
        extract_polygons() %>%
        build_polygons() %>%
        explore_polygons()

    p %>%
        select(coordinates) %>%
        unnest_wider(coordinates) %>%
        gather(latlon, value)

    df %>%
        filter(label == 'prioritization', nodes > 0) %>%
        filter(geom_type == 'Polygon', gid == 81) %>% #glimpse()
        unpack_coordinates() %>% glimpse() #View()


    p <- df %>%
        filter(label == 'prioritization', nodes > 0) %>%
        filter(geom_type == 'Polygon', gid == 81)

    to_points <- function(coords) {
        #g <- st_as_text(st_sfc(st_multipoint(matrix(unlist(coords), ncol = 2)), crs = 4326))
        g <- st_as_text(st_multipoint(matrix(unlist(coords), ncol = 2)))
        #g <- st_multipoint(matrix(unlist(coords), ncol = 2))
    }

    to_line <- function(coords) {
        #print(coords)
        #g <- st_as_text(st_sfc(st_linestring(matrix(unlist(coords), ncol = 2)), crs = 4326))
        g <- st_as_text(st_linestring(matrix(unlist(coords), ncol = 2)))
        #g <- st_linestring(matrix(unlist(coords), ncol = 2))
        #print(g)
    }

    to_polygon <- function(coords) {
        #print(coords)
        #g <- st_as_text(st_sfc(st_polygon(list(matrix(unlist(coords), ncol = 2))), crs = 4326))
        g <- st_as_text(st_polygon(list(matrix(unlist(coords), ncol = 2))))
        #g <- st_polygon(list(matrix(unlist(coords), ncol = 2)))
        #print(g)
    }

    df %>%
        filter(label == 'prioritization', nodes > 0) %>%
        filter(geom_type == 'Polygon') %>% #head() %>% #View()
        #filter(gid == 81) %>%
        filter(gid %in% c(81, 408, 770)) %>%
        #mutate(geometry = mapply(to_points, coordinates)) %>% glimpse()
        #mutate(geometry = mapply(to_line, coordinates)) %>% glimpse()
        #mutate(geometry = mapply(to_polygon, coordinates)) %>% #glimpse()
        rowwise() %>%
        #mutate(geometry = to_points(coordinates)) %>% glimpse()
        #mutate(geometry = to_line(coordinates)) %>% #glimpse()
        mutate(geometry = to_polygon(coordinates)) %>%
        ungroup() %>% #View()
        st_as_sf(wkt = "geometry") %>% #glimpse()
        ggplot() +
        geom_sf()




    #01) 30.8547 3.5179
    #57) 30.8547 3.5179

    # matrix(unlist(p$coordinates), ncol = 2, byrow = F) %>%
    #     as.data.frame() %>%
    #     st_as_sf(coords = c("V1", "V2"), crs = 4326) %>%
    #     ggplot() +
    #     geom_sf()
    #
    # st_linestring(matrix(unlist(p$coordinates), ncol = 2, byrow = F)) %>% #class()
    #     ggplot() +
    #     geom_sf()
    #
    # st_sfc(st_polygon(list(matrix(unlist(p$coordinates), ncol = 2, byrow = F)))) %>% class()
    #     ggplot() +
    #     geom_sf()




    df %>%
        filter(label == 'prioritization', nodes > 0) %>%
        filter(geom_type == 'Polygon', gid == 81) %>%
        unnest_wider(col = "coordinates") %>% #View()
        janitor::clean_names() %>%
        gather("coords_pos", "lonlat", -c(1:length(names(df)) -1) ) %>%
        mutate(
            coords_pos = as.integer(gsub(pattern = "\\D", "", coords_pos)),
            coords_type = case_when(
                coords_pos <= nodes ~ "longitude",
                TRUE ~ "latitude"
            ),
            coords_pos = case_when(
                coords_pos > nodes ~ coords_pos - nodes,
                TRUE ~ coords_pos
            )
        ) %>%
        spread(coords_type, lonlat) %>% View()


    p <- df %>%
        filter(label == 'prioritization', nodes > 0) %>%
        filter(geom_type == 'Polygon')

    p %>%
        #select(-geom_type) %>% glimpse()
        pull(id) %>%
        map_dfr(function(id) {
            print(id)

            coords <- p %>%
                filter(id == id)

            print(coords)

            coords <- coords %>%
                unpack_coordinates()

            #return(coords)

        }) %>% View()





    ## Deal with MultiPolygons
    p <- df %>%
        filter(label == 'prioritization', nodes > 0) %>% #View()
        filter(geom_type == 'MultiPolygon') %>%
        unnest_longer(col = coordinates) %>% #View()
        mutate(
            geom_type = "Polygon",
            nodes = as.integer(lengths(coordinates) / 2)
        ) #%>% #View()
        #extract_psnu() #%>%

    p %>%
        pull(id) %>%
        unique() %>%
        map_dfr(unpack_polygons, p) %>% View()
        build_polygons() %>%
        explore_polygons()

    p %>% glimpse()

    p %>%
        filter(id == "Ml7XhDDDSxr") %>%
        mutate(gid2 = row_number()) %>%
        filter(gid2 == 1) %>%
        select(operatingunit:gid, gid2, nodes, coordinates) %>%
        unnest_wider(col = "coordinates") %>%
        janitor::clean_names() %>%
        gather("coords_pos", "lonlat", -c(1:length(names(p))) ) %>% #View()
        mutate(
            coords_pos = as.integer(gsub(pattern = "\\D", "", coords_pos))
        ) %>% #View()
        mutate(
            coords_type = case_when(
                coords_pos <= nodes ~ "longitude",
                TRUE ~ "latitude"
            )
        ) %>% #View()
        mutate(
            coords_pos = case_when(
                coords_pos > nodes ~ coords_pos - nodes,
                TRUE ~ coords_pos
            )
        ) %>% #View()
        spread(coords_type, lonlat) %>% View()


    df %>%
        extract_polygons()



    zones <- df %>%
        extract_polygons()

    zones %>%
        build_polygons() %>%
        explore_polygons()




