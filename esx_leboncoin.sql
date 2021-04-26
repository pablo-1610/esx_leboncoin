CREATE TABLE `esx_leboncoin` (
  `id` int(11) NOT NULL,
  `license` varchar(80) NOT NULL,
  `name` text NOT NULL,
  `description` varchar(150) NOT NULL,
  `model` text NOT NULL,
  `price` int(10) NOT NULL,
  `createdAt` text NOT NULL,
  `plate` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `esx_leboncoin`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `esx_leboncoin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
COMMIT;
