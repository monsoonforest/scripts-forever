library(tesseract)
library(magick)
library(magrittr)

text <- image_read("Aguli-a-hq.jpeg") %>%
#  image_resize("2000") %>%
  image_convert(colorspace = 'gray') %>%
 # image_trim() %>%
  image_ocr()

cat(text)

write.csv(text, "Aguli-hq-text.csv")