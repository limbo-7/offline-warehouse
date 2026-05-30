-- DWS - dws_traffic_page_visitor_page_view_1d - 流量域访客页面浏览近1日汇总表

DROP TABLE IF EXISTS dws_traffic_page_visitor_page_view_1d;
CREATE EXTERNAL TABLE dws_traffic_page_visitor_page_view_1d
(
    `mid_id`         STRING COMMENT '访客ID',
    `brand`          string comment '手机品牌',
    `model`          string comment '手机型号',
    `operate_system` string comment '操作系统',
    `page_id`        STRING COMMENT '页面ID',
    `during_time_1d` BIGINT COMMENT '最近1日浏览时长',
    `view_count_1d`  BIGINT COMMENT '最近1日访问次数'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/gmall/dws/dws_traffic_page_visitor_page_view_1d'
    TBLPROPERTIES ('orc.compress' = 'snappy');
-- 数据装载

insert overwrite table dws_traffic_page_visitor_page_view_1d partition(dt='2022-06-08')
select
    mid_id,
    brand,
    model,
    operate_system,
    page_id,
    sum(during_time),
    count(*)
from dwd_traffic_page_view_inc
where dt='2022-06-08'
group by mid_id,brand,model,operate_system,page_id;



   exit

dws_trade_province_order_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
-- 数据装载

insert overwrite table ${APP}.dws_trade_province_order_1d partition(dt)
select
    province_id,
    province_name,
    area_code,
    iso_code,
    iso_3166_2,
    order_count_1d,
    order_original_amount_1d,
    activity_reduce_amount_1d,
    coupon_reduce_amount_1d,
    order_total_amount_1d,
    dt
from
(
    select
        province_id,
        count(distinct(order_id)) order_count_1d,
        sum(split_original_amount) order_original_amount_1d,
        sum(nvl(split_activity_amount,0)) activity_reduce_amount_1d,
        sum(nvl(split_coupon_amount,0)) coupon_reduce_amount_1d,
        sum(split_total_amount) order_total_amount_1d,
        dt
    from ${APP}.dwd_trade_order_detail_inc
    group by province_id,dt
)o
left join
(
    select
        id,
        province_name,
        area_code,
        iso_code,
        iso_3166_2
    from ${APP}.dim_province_full
    where dt='$do_date'
)p
on o.province_id=p.id;
dws_trade_user_cart_add_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_cart_add_1d partition(dt)
select
    user_id,
    count(*),
    sum(sku_num),
    dt
from ${APP}.dwd_trade_cart_add_inc
group by user_id,dt;
dws_trade_user_order_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_order_1d partition(dt)
select
    user_id,
    count(distinct(order_id)),
    sum(sku_num),
    sum(split_original_amount),
    sum(nvl(split_activity_amount,0)),
    sum(nvl(split_coupon_amount,0)),
    sum(split_total_amount),
    dt
from ${APP}.dwd_trade_order_detail_inc
group by user_id,dt;

dws_trade_user_payment_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_payment_1d partition(dt)
select
    user_id,
    count(distinct(order_id)),
    sum(sku_num),
    sum(split_payment_amount),
    dt
from ${APP}.dwd_trade_pay_detail_suc_inc
group by user_id,dt;
dws_trade_user_sku_order_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.vectorized.execution.enabled = false;
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_sku_order_1d partition(dt)
select
    user_id,
    id,
    sku_name,
    category1_id,
    category1_name,
    category2_id,
    category2_name,
    category3_id,
    category3_name,
    tm_id,
    tm_name,
    order_count_1d,
    order_num_1d,
    order_original_amount_1d,
    activity_reduce_amount_1d,
    coupon_reduce_amount_1d,
    order_total_amount_1d,
    dt
from
(
    select
        dt,
        user_id,
        sku_id,
        count(*) order_count_1d,
        sum(sku_num) order_num_1d,
        sum(split_original_amount) order_original_amount_1d,
        sum(nvl(split_activity_amount,0.0)) activity_reduce_amount_1d,
        sum(nvl(split_coupon_amount,0.0)) coupon_reduce_amount_1d,
        sum(split_total_amount) order_total_amount_1d
    from ${APP}.dwd_trade_order_detail_inc
    group by dt,user_id,sku_id
)od
left join
(
    select
        id,
        sku_name,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        tm_id,
        tm_name
    from ${APP}.dim_sku_full
    where dt='$do_date'
)sku
on od.sku_id=sku.id;
set hive.vectorized.execution.enabled = true;

dws_tool_user_coupon_coupon_used_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
-- 数据装载

insert overwrite table ${APP}.dws_tool_user_coupon_coupon_used_1d partition(dt)
select
    user_id,
    coupon_id,
    coupon_name,
    coupon_type_code,
    coupon_type_name,
    benefit_rule,
    used_count,
    dt
from
(
    select
        dt,
        user_id,
        coupon_id,
        count(*) used_count
    from ${APP}.dwd_tool_coupon_used_inc
    group by dt,user_id,coupon_id
)t1
left join
(
    select
        id,
        coupon_name,
        coupon_type_code,
        coupon_type_name,
        benefit_rule
    from ${APP}.dim_coupon_full
    where dt='$do_date'
)t2
on t1.coupon_id=t2.id;
dws_interaction_sku_favor_add_1d="
set hive.exec.dynamic.partition.mode=nonstrict;
-- 数据装载

insert overwrite table ${APP}.dws_interaction_sku_favor_add_1d partition(dt)
select
    sku_id,
    sku_name,
    category1_id,
    category1_name,
    category2_id,
    category2_name,
    category3_id,
    category3_name,
    tm_id,
    tm_name,
    favor_add_count,
    dt
from
(
    select
        dt,
        sku_id,
        count(*) favor_add_count
    from ${APP}.dwd_interaction_favor_add_inc
    group by dt,sku_id
)favor
left join
(
    select
        id,
        sku_name,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        tm_id,
        tm_name
    from ${APP}.dim_sku_full
    where dt='$do_date'
)sku
on favor.sku_id=sku.id;

dws_traffic_page_visitor_page_view_1d="
-- 数据装载

insert overwrite table ${APP}.dws_traffic_page_visitor_page_view_1d partition(dt='$do_date')
select
    mid_id,
    brand,
    model,
    operate_system,
    page_id,
    sum(during_time),
    count(*)
from ${APP}.dwd_traffic_page_view_inc
where dt='$do_date'
group by mid_id,brand,model,operate_system,page_id;
dws_traffic_session_page_view_1d="
-- 数据装载

insert overwrite table ${APP}.dws_traffic_session_page_view_1d partition(dt='$do_date')
select
    session_id,
    mid_id,
    brand,
    model,
    operate_system,
    version_code,
    channel,
    sum(during_time),
    count(*)
from ${APP}.dwd_traffic_page_view_inc
where dt='$do_date'
group by session_id,mid_id,brand,model,operate_system,version_code,channel;




dws_trade_province_order_1d="
-- 数据装载

insert overwrite table ${APP}.dws_trade_province_order_1d partition(dt='$do_date')
select
    province_id,
    province_name,
    area_code,
    iso_code,
    iso_3166_2,
    order_count_1d,
    order_original_amount_1d,
    activity_reduce_amount_1d,
    coupon_reduce_amount_1d,
    order_total_amount_1d
from
(
    select
        province_id,
        count(distinct(order_id)) order_count_1d,
        sum(split_original_amount) order_original_amount_1d,
        sum(nvl(split_activity_amount,0)) activity_reduce_amount_1d,
        sum(nvl(split_coupon_amount,0)) coupon_reduce_amount_1d,
        sum(split_total_amount) order_total_amount_1d
    from ${APP}.dwd_trade_order_detail_inc
    where dt='$do_date'
    group by province_id
)o
left join
(
    select
        id,
        province_name,
        area_code,
        iso_code,
        iso_3166_2
    from ${APP}.dim_province_full
    where dt='$do_date'
)p
on o.province_id=p.id;
dws_trade_user_cart_add_1d="
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_cart_add_1d partition(dt='$do_date')
select
    user_id,
    count(*),
    sum(sku_num)
from ${APP}.dwd_trade_cart_add_inc
where dt='$do_date'
group by user_id;
dws_trade_user_order_1d="
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_order_1d partition(dt='$do_date')
select
    user_id,
    count(distinct(order_id)),
    sum(sku_num),
    sum(split_original_amount),
    sum(nvl(split_activity_amount,0)),
    sum(nvl(split_coupon_amount,0)),
    sum(split_total_amount)
from ${APP}.dwd_trade_order_detail_inc
where dt='$do_date'
group by user_id;

dws_trade_user_payment_1d="
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_payment_1d partition(dt='$do_date')
select
    user_id,
    count(distinct(order_id)),
    sum(sku_num),
    sum(split_payment_amount)
from ${APP}.dwd_trade_pay_detail_suc_inc
where dt='$do_date'
group by user_id;
dws_trade_user_sku_order_1d="
set hive.vectorized.execution.enabled = false;
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_sku_order_1d partition(dt='$do_date')
select
    user_id,
    id,
    sku_name,
    category1_id,
    category1_name,
    category2_id,
    category2_name,
    category3_id,
    category3_name,
    tm_id,
    tm_name,
    order_count,
    order_num,
    order_original_amount,
    activity_reduce_amount,
    coupon_reduce_amount,
    order_total_amount
from
(
    select
        user_id,
        sku_id,
        count(*) order_count,
        sum(sku_num) order_num,
        sum(split_original_amount) order_original_amount,
        sum(nvl(split_activity_amount,0)) activity_reduce_amount,
        sum(nvl(split_coupon_amount,0)) coupon_reduce_amount,
        sum(split_total_amount) order_total_amount
    from ${APP}.dwd_trade_order_detail_inc
    where dt='$do_date'
    group by user_id,sku_id
)od
left join
(
    select
        id,
        sku_name,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        tm_id,
        tm_name
    from ${APP}.dim_sku_full
    where dt='$do_date'
)sku
on od.sku_id=sku.id;
set hive.vectorized.execution.enabled = true;

dws_interaction_sku_favor_add_1d="
-- 数据装载

insert overwrite table ${APP}.dws_interaction_sku_favor_add_1d partition(dt='$do_date')
select
    sku_id,
    sku_name,
    category1_id,
    category1_name,
    category2_id,
    category2_name,
    category3_id,
    category3_name,
    tm_id,
    tm_name,
    favor_add_count
from
(
    select
        sku_id,
        count(*) favor_add_count
    from ${APP}.dwd_interaction_favor_add_inc
    where dt='$do_date'
    group by sku_id
)favor
left join
(
    select
        id,
        sku_name,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        tm_id,
        tm_name
    from ${APP}.dim_sku_full
    where dt='$do_date'
)sku
on favor.sku_id=sku.id;

dws_tool_user_coupon_coupon_used_1d="
-- 数据装载

insert overwrite table ${APP}.dws_tool_user_coupon_coupon_used_1d partition(dt='$do_date')
select
    user_id,
    coupon_id,
    coupon_name,
    coupon_type_code,
    coupon_type_name,
    benefit_rule,
    used_count
from
(
    select
        user_id,
        coupon_id,
        count(*) used_count
    from ${APP}.dwd_tool_coupon_used_inc
    where dt='$do_date'
    group by user_id,coupon_id
)t1
left join
(
    select
        id,
        coupon_name,
        coupon_type_code,
        coupon_type_name,
        benefit_rule
    from ${APP}.dim_coupon_full
    where dt='$do_date'
)t2
on t1.coupon_id=t2.id;

dws_traffic_page_visitor_page_view_1d="
-- 数据装载

insert overwrite table ${APP}.dws_traffic_page_visitor_page_view_1d partition(dt='$do_date')
select
    mid_id,
    brand,
    model,
    operate_system,
    page_id,
    sum(during_time),
    count(*)
from ${APP}.dwd_traffic_page_view_inc
where dt='$do_date'
group by mid_id,brand,model,operate_system,page_id;
dws_traffic_session_page_view_1d="
-- 数据装载

insert overwrite table ${APP}.dws_traffic_session_page_view_1d partition(dt='$do_date')
select
    session_id,
    mid_id,
    brand,
    model,
    operate_system,
    version_code,
    channel,
    sum(during_time),
    count(*)
from ${APP}.dwd_traffic_page_view_inc
where dt='$do_date'
group by session_id,mid_id,brand,model,operate_system,version_code,channel;
