-- DIM - 日期维度临时表
-- 用途: 日期维度中间表，用于生成 dim_date
-- ================================================================

DROP TABLE IF EXISTS tmp_dim_date_info;
CREATE EXTERNAL TABLE tmp_dim_date_info (
    `date_id`       STRING,
    `week_id`       STRING,
    `week_day`      STRING,
    `day`            STRING,
    `month`          STRING,
    `quarter`       STRING,
    `year`           STRING,
    `is_workday`    STRING,
    `holiday_id`    STRING
) COMMENT '时间维度表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/gmall/tmp/tmp_dim_date_info/';

-- 数据装载

-- 数据装载
insert overwrite table dim_date select * from tmp_dim_date_info;
select * from dim_date;