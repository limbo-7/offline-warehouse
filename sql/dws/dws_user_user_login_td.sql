-- DWS - dws_user_user_login_td - 用户域用户登录累积汇总表

DROP TABLE IF EXISTS dws_user_user_login_td;
CREATE EXTERNAL TABLE dws_user_user_login_td
(
    `user_id`          STRING COMMENT '用户ID',
    `login_date_last`  STRING COMMENT '历史至今末次登录日期',
    `login_date_first` STRING COMMENT '历史至今首次登录日期',
    `login_count_td`   BIGINT COMMENT '历史至今累计登录次数'
    PARTITIONED BY (`dt` STRING)
    STORED AS ORC
    LOCATION '/warehouse/gmall/dws/dws_user_user_login_td'
    TBLPROPERTIES ('orc.compress' = 'snappy');
-- 数据装载

insert overwrite table dws_user_user_login_td partition (dt = '2022-06-08')
select u.id                                                         user_id,
       nvl(login_date_last, date_format(create_time, 'yyyy-MM-dd')) login_date_last,
       date_format(create_time, 'yyyy-MM-dd')                       login_date_first,
       nvl(login_count_td, 1)                                       login_count_td
from (
         select id,
                create_time
         from dim_user_zip
         where dt = '9999-12-31'
     ) u
         left join
     (
         select user_id,
                max(dt)  login_date_last,
                count(*) login_count_td
         from dwd_user_login_inc
         group by user_id
     ) l
     on u.id = l.user_id;
-- 数据装载

insert overwrite table dws_user_user_login_td partition (dt = '2022-06-09')
select nvl(old.user_id, new.user_id)                                        user_id,
       if(new.user_id is null, old.login_date_last, '2022-06-09')           login_date_last,
       if(old.login_date_first is null, '2022-06-09', old.login_date_first) login_date_first,
       nvl(old.login_count_td, 0) + nvl(new.login_count_1d, 0)              login_count_td
from (
         select user_id,
                login_date_last,
                login_date_first,
                login_count_td
         from dws_user_user_login_td
         where dt = date_add('2022-06-09', -1)
     ) old
         full outer join
     (
         select user_id,
                count(*) login_count_1d
         from dwd_user_login_inc
         where dt = '2022-06-09'
         group by user_id
     ) new
     on old.user_id = new.user_id;



   exit

dws_trade_user_order_td="
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_order_td partition(dt='$do_date')
select
    user_id,
    min(dt) login_date_first,
    max(dt) login_date_last,
    sum(order_count_1d) order_count,
    sum(order_num_1d) order_num,
    sum(order_original_amount_1d) original_amount,
    sum(activity_reduce_amount_1d) activity_reduce_amount,
    sum(coupon_reduce_amount_1d) coupon_reduce_amount,
    sum(order_total_amount_1d) total_amount
from ${APP}.dws_trade_user_order_1d
group by user_id;


dws_user_user_login_td="
-- 数据装载

insert overwrite table ${APP}.dws_user_user_login_td partition (dt = '$do_date')
select u.id                                                         user_id,
       nvl(login_date_last, date_format(create_time, 'yyyy-MM-dd')) login_date_last,
       date_format(create_time, 'yyyy-MM-dd')                       login_date_first,
       nvl(login_count_td, 1)                                       login_count_td
from (
         select id,
                create_time
         from ${APP}.dim_user_zip
         where dt = '9999-12-31'
     ) u
         left join
     (
         select user_id,
                max(dt)  login_date_last,
                count(*) login_count_td
         from ${APP}.dwd_user_login_inc
         group by user_id
     ) l
     on u.id = l.user_id;




dws_trade_user_order_td="
-- 数据装载

insert overwrite table ${APP}.dws_trade_user_order_td partition (dt = '$do_date')
select nvl(old.user_id, new.user_id),
       if(old.user_id is not null, old.order_date_first, '$do_date'),
       if(new.user_id is not null, '$do_date', old.order_date_last),
       nvl(old.order_count_td, 0) + nvl(new.order_count_1d, 0),
       nvl(old.order_num_td, 0) + nvl(new.order_num_1d, 0),
       nvl(old.original_amount_td, 0) + nvl(new.order_original_amount_1d, 0),
       nvl(old.activity_reduce_amount_td, 0) + nvl(new.activity_reduce_amount_1d, 0),
       nvl(old.coupon_reduce_amount_td, 0) + nvl(new.coupon_reduce_amount_1d, 0),
       nvl(old.total_amount_td, 0) + nvl(new.order_total_amount_1d, 0)
from (
         select user_id,
                order_date_first,
                order_date_last,
                order_count_td,
                order_num_td,
                original_amount_td,
                activity_reduce_amount_td,
                coupon_reduce_amount_td,
                total_amount_td
         from ${APP}.dws_trade_user_order_td
         where dt = date_add('$do_date', -1)
     ) old
         full outer join
     (
         select user_id,
                order_count_1d,
                order_num_1d,
                order_original_amount_1d,
                activity_reduce_amount_1d,
                coupon_reduce_amount_1d,
                order_total_amount_1d
         from ${APP}.dws_trade_user_order_1d
         where dt = '$do_date'
     ) new
     on old.user_id = new.user_id;

dws_user_user_login_td="
-- 数据装载

insert overwrite table ${APP}.dws_user_user_login_td partition (dt = '$do_date')
select nvl(old.user_id, new.user_id)                                        user_id,
       if(new.user_id is null, old.login_date_last, '$do_date')           login_date_last,
       if(old.login_date_first is null, '$do_date', old.login_date_first) login_date_first,
       nvl(old.login_count_td, 0) + nvl(new.login_count_1d, 0)              login_count_td
from (
         select user_id,
                login_date_last,
                login_date_first,
                login_count_td
         from ${APP}.dws_user_user_login_td
         where dt = date_add('$do_date', -1)
     ) old
         full outer join
     (
         select user_id,
                count(*) login_count_1d
         from ${APP}.dwd_user_login_inc
         where dt = '$do_date'
         group by user_id
     ) new
     on old.user_id = new.user_id;


select
    count(distinct(user_id))
from
(
    select
        user_id
    from
    (
        select
            user_id,
            date_sub(dt,rank() over(partition by user_id order by dt)) diff
        from dws_trade_user_order_1d
        where dt>=date_add('2022-06-08',-6)
    )t1
    group by user_id,diff
    having count(*)>=3
)t2;

select
    count(*)
from
(
    select
        user_id,
        sum(num) s
    from
    (
        select
            user_id,
                when '2022-06-08' then 1
                when '2022-06-07' then 10
                when '2022-06-06' then 100
                when '2022-06-05' then 1000
                when '2022-06-04' then 10000
                when '2022-06-03' then 100000
                when '2022-06-02' then 1000000
                else 0
            end num
        from dws_trade_user_order_1d
        where dt>=date_add('2022-06-08',-6)
    )t1
    group by user_id
)t2
where cast(s as string) like "%111%";

select
    count(distinct(user_id))
from
(
    select
        user_id,
        datediff(lead(dt,2,'9999-12-31') over(partition by user_id order by dt),dt) diff
    from dws_trade_user_order_1d
    where dt>=date_add('2022-06-08',-6)
)t1
where diff<=3;
