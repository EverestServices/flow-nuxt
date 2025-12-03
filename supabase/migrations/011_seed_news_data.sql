-- Seed news data with sample articles
-- Create user profiles for all existing users in auth.users

-- Ensure user profiles exist for all auth users
INSERT INTO public.user_profiles (user_id, company_id, first_name, last_name)
SELECT
    id as user_id,
    '550e8400-e29b-41d4-a716-446655440000'::uuid as company_id,  -- Default demo company
    COALESCE(raw_user_meta_data->>'first_name', 'User') as first_name,
    COALESCE(raw_user_meta_data->>'last_name', SPLIT_PART(email, '@', 1)) as last_name
FROM auth.users
WHERE NOT EXISTS (
    SELECT 1 FROM public.user_profiles WHERE user_profiles.user_id = users.id
);

-- Seed sample news articles
INSERT INTO public.news_articles (
    title, slug, excerpt, content, category_id, company_id, is_global, is_featured, is_published, published_at, author_id, tags, featured_image_url
) VALUES

-- Featured Global Articles
(
    'Flow Platform 2.0 Launch: Revolutionary Changes Ahead',
    'flow-platform-2-launch-revolutionary-changes',
    'We are excited to announce the official launch of Flow Platform 2.0, bringing unprecedented capabilities to our energy management suite.',
    '<h2>A New Era of Energy Management</h2><p>After months of development and testing, we are thrilled to introduce Flow Platform 2.0. This major update represents the most significant advancement in our platform''s history.</p><h3>Key Features</h3><ul><li><strong>AI-Powered Analytics:</strong> Advanced machine learning algorithms now provide predictive insights for energy consumption patterns.</li><li><strong>Real-time Monitoring:</strong> Enhanced dashboard with live data streaming and instant alerts.</li><li><strong>Mobile Integration:</strong> Complete mobile app redesign with offline capabilities.</li><li><strong>Advanced Reporting:</strong> Customizable reports with automated scheduling and distribution.</li></ul><p>Our beta users have reported an average of 23% improvement in energy efficiency within the first month of using the new features.</p>',
    (SELECT id FROM public.news_categories WHERE slug = 'product-updates'),
    NULL,
    TRUE,
    TRUE,
    TRUE,
    NOW() - INTERVAL '2 hours',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['platform', 'launch', 'features', 'ai', 'mobile'],
    'https://images.unsplash.com/photo-1518709268805-4e9042af2176?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Record-Breaking Q4 Results: 150% Growth in Clean Energy Adoption',
    'record-breaking-q4-results-clean-energy-growth',
    'Our fourth quarter results show unprecedented growth in clean energy adoption, with over 10,000 new installations completed.',
    '<h2>Exceeding All Expectations</h2><p>We are proud to announce that Q4 2024 has been our most successful quarter to date, with remarkable achievements across all metrics.</p><h3>Key Achievements</h3><ul><li><strong>10,247 New Installations:</strong> Solar and wind energy systems deployed across 47 states</li><li><strong>150% YoY Growth:</strong> Compared to Q4 2023, we have achieved unprecedented expansion</li><li><strong>Customer Satisfaction:</strong> 98.7% customer satisfaction rating, our highest ever</li><li><strong>Carbon Impact:</strong> Our installations will prevent 2.3 million tons of CO2 emissions annually</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'company-news'),
    NULL,
    TRUE,
    TRUE,
    TRUE,
    NOW() - INTERVAL '1 day',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['results', 'growth', 'clean-energy', 'installations', 'success'],
    'https://images.unsplash.com/photo-1466611653911-95081537e5b7?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Industry Report: Renewable Energy Market Reaches $1.1 Trillion Globally',
    'renewable-energy-market-trillion-globally',
    'The latest industry analysis reveals that the global renewable energy market has crossed the historic $1.1 trillion milestone.',
    '<h2>Renewable Energy Market Milestone</h2><p>According to the latest comprehensive market analysis by Global Energy Intelligence, the renewable energy sector has achieved a historic milestone by reaching $1.1 trillion in global market value.</p><h3>Market Breakdown</h3><ul><li><strong>Solar Power:</strong> $420 billion (38% of market)</li><li><strong>Wind Energy:</strong> $380 billion (35% of market)</li><li><strong>Hydroelectric:</strong> $180 billion (16% of market)</li><li><strong>Other Renewables:</strong> $120 billion (11% of market)</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'industry-updates'),
    NULL,
    TRUE,
    TRUE,
    TRUE,
    NOW() - INTERVAL '3 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['industry', 'market-analysis', 'renewable-energy', 'global', 'trillion'],
    'https://images.unsplash.com/photo-1509391366360-2e959784a276?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

-- Company-specific Articles
(
    'New Advanced Solar Panel Certification Course Now Available',
    'advanced-solar-panel-certification-course',
    'Enhance your expertise with our comprehensive new certification program covering the latest solar panel technologies and installation techniques.',
    '<p>We are excited to launch our most comprehensive solar panel certification course to date. This advanced program covers cutting-edge photovoltaic technologies, installation best practices, and maintenance protocols.</p><h3>Course Highlights</h3><ul><li>40-hour comprehensive curriculum</li><li>Hands-on installation training</li><li>Latest industry safety standards</li><li>Business development modules</li><li>Certification valid for 3 years</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'training-education'),
    'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44',
    FALSE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '1 day',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['training', 'solar', 'certification', 'education'],
    'https://images.unsplash.com/photo-1508514177221-188b1cf16e9d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

-- Global Articles
(
    'Smart Grid Integration: The Future of Energy Distribution',
    'smart-grid-integration-future-energy-distribution',
    'Exploring how smart grid technology is revolutionizing energy distribution networks and creating opportunities for renewable energy integration.',
    '<h2>The Smart Grid Revolution</h2><p>Smart grid technology represents a fundamental shift in how we think about energy distribution. By integrating advanced sensors, communication systems, and automated controls, smart grids enable two-way communication between utilities and consumers.</p><h3>Key Benefits</h3><ul><li><strong>Enhanced Reliability:</strong> Automatic fault detection and self-healing capabilities</li><li><strong>Improved Efficiency:</strong> Real-time optimization of energy flow</li><li><strong>Renewable Integration:</strong> Better accommodation of variable renewable sources</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'industry-updates'),
    NULL,
    TRUE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '2 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['smart-grid', 'technology', 'distribution', 'infrastructure'],
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Employee Spotlight: Sarah Johnson Wins National Innovation Award',
    'employee-spotlight-sarah-johnson-innovation-award',
    'Congratulations to our Senior Energy Engineer Sarah Johnson for receiving the National Clean Energy Innovation Award for her groundbreaking work.',
    '<h2>Outstanding Recognition</h2><p>We are incredibly proud to announce that Sarah Johnson, our Senior Energy Engineer, has been awarded the prestigious National Clean Energy Innovation Award by the American Energy Association.</p><h3>Award-Winning Innovation</h3><p>Sarah''s revolutionary work on "Adaptive Solar Tracking Systems" has resulted in a 34% increase in solar panel efficiency compared to traditional fixed installations.</p>',
    (SELECT id FROM public.news_categories WHERE slug = 'company-news'),
    'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44',
    FALSE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '3 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['employee', 'award', 'innovation', 'solar', 'recognition'],
    'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Wind Energy Costs Drop 70% Over Decade, Report Shows',
    'wind-energy-costs-drop-70-percent-decade',
    'A comprehensive new study reveals that wind energy costs have plummeted by 70% over the past decade, making it the most cost-effective power source.',
    '<h2>Historic Cost Reductions</h2><p>The International Renewable Energy Agency (IRENA) has released its annual cost analysis, showing that wind energy has achieved unprecedented cost reductions of 70% over the past decade.</p><h3>Driving Factors</h3><ul><li><strong>Technological Advances:</strong> Larger, more efficient turbines</li><li><strong>Economies of Scale:</strong> Mass production reducing manufacturing costs</li><li><strong>Competitive Markets:</strong> Increased competition driving innovation</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'industry-updates'),
    NULL,
    TRUE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '4 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['wind-energy', 'costs', 'report', 'industry', 'analysis'],
    'https://images.unsplash.com/photo-1532601224476-15c79f2f7a51?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'New Mobile App Feature: Real-Time Energy Monitoring',
    'mobile-app-real-time-energy-monitoring',
    'Our latest mobile app update introduces real-time energy monitoring capabilities, giving users unprecedented control over their energy consumption.',
    '<h2>Enhanced Mobile Experience</h2><p>Version 3.2 of our mobile app brings powerful new features that put energy management at your fingertips. The highlight is our new real-time monitoring dashboard that provides instant insights into your energy usage patterns.</p><h3>New Features</h3><ul><li><strong>Live Data Streaming:</strong> See your energy consumption update every 5 seconds</li><li><strong>Smart Alerts:</strong> Customizable notifications for usage spikes or anomalies</li><li><strong>Historical Comparisons:</strong> Compare current usage to previous periods</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'product-updates'),
    NULL,
    TRUE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '5 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['mobile-app', 'monitoring', 'real-time', 'features'],
    'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Energy Storage Breakthrough: Lithium-Ion Prices Fall 89% Since 2010',
    'energy-storage-lithium-ion-prices-fall-89-percent',
    'Revolutionary cost reductions in lithium-ion battery technology are making energy storage accessible for residential and commercial applications.',
    '<h2>Battery Revolution Continues</h2><p>According to BloombergNEF''s latest battery price survey, lithium-ion battery pack prices have fallen an astounding 89% since 2010, reaching $137/kWh in 2024.</p><h3>Price Evolution</h3><ul><li><strong>2010:</strong> $1,200/kWh</li><li><strong>2015:</strong> $350/kWh</li><li><strong>2020:</strong> $200/kWh</li><li><strong>2024:</strong> $137/kWh</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'industry-updates'),
    NULL,
    TRUE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '6 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['energy-storage', 'batteries', 'lithium-ion', 'costs', 'technology'],
    'https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Quarterly Safety Training Schedule Released',
    'quarterly-safety-training-schedule-released',
    'Our comprehensive Q1 2025 safety training schedule is now available, featuring enhanced protocols and new certification requirements.',
    '<h2>Comprehensive Safety Program</h2><p>Our Q1 2025 safety training schedule has been released, featuring updated protocols and new certification requirements to ensure the highest safety standards across all operations.</p><h3>Training Sessions Include</h3><ul><li><strong>Electrical Safety Fundamentals:</strong> January 15-16</li><li><strong>Rooftop Installation Protocols:</strong> January 22-23</li><li><strong>Emergency Response Procedures:</strong> February 5-6</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'training-education'),
    'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44',
    FALSE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '7 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['safety', 'training', 'certification', 'schedule'],
    'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Partnership Announcement: Joining Forces with GreenTech Solutions',
    'partnership-greentech-solutions-announcement',
    'We are excited to announce our strategic partnership with GreenTech Solutions, expanding our capabilities in commercial energy systems.',
    '<h2>Strategic Partnership</h2><p>We are thrilled to announce a strategic partnership with GreenTech Solutions, a leading provider of commercial energy management systems. This collaboration will significantly expand our service offerings and market reach.</p><h3>Partnership Benefits</h3><ul><li><strong>Enhanced Service Portfolio:</strong> Access to advanced commercial energy systems</li><li><strong>Expanded Geographic Coverage:</strong> Combined operations across 15 additional states</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'company-news'),
    NULL,
    TRUE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '8 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['partnership', 'collaboration', 'greentech', 'expansion'],
    'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Federal Tax Incentives Extended Through 2030',
    'federal-tax-incentives-extended-2030',
    'Great news for renewable energy adoption: federal tax incentives for solar and wind installations have been extended through 2030.',
    '<h2>Extended Federal Support</h2><p>In a significant boost for the renewable energy sector, Congress has passed legislation extending federal tax incentives for solar and wind installations through 2030, providing long-term certainty for investors and consumers.</p><h3>Key Provisions</h3><ul><li><strong>Solar Investment Tax Credit (ITC):</strong> 30% credit maintained through 2030</li><li><strong>Production Tax Credit (PTC):</strong> Extended for wind projects</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'industry-updates'),
    NULL,
    TRUE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '9 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['tax-incentives', 'federal', 'policy', 'renewable-energy'],
    'https://images.unsplash.com/photo-1589549720811-ac4ba4bdc7a6?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Customer Success Story: 90% Energy Cost Reduction in Manufacturing',
    'customer-success-manufacturing-90-percent-reduction',
    'Learn how Midwest Manufacturing achieved a 90% reduction in energy costs through our comprehensive solar and efficiency solutions.',
    '<h2>Transformational Results</h2><p>Midwest Manufacturing, a family-owned automotive parts manufacturer, has achieved remarkable results with our comprehensive energy solution, reducing their energy costs by 90% while significantly improving their environmental footprint.</p><h3>Results</h3><ul><li>90% reduction in electricity costs</li><li>75% reduction in carbon emissions</li><li>$2.3 million in annual savings</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'general'),
    'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44',
    FALSE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '10 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['customer-success', 'manufacturing', 'cost-reduction', 'solar'],
    'https://images.unsplash.com/photo-1581092160607-ee22621dd758?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Webinar Series: Advanced Energy Management Strategies',
    'webinar-series-advanced-energy-management',
    'Join our expert-led webinar series covering advanced energy management strategies for commercial and industrial applications.',
    '<h2>Educational Webinar Series</h2><p>We are launching a comprehensive webinar series designed to help energy professionals stay current with the latest technologies and strategies in energy management.</p><h3>Upcoming Sessions</h3><ul><li><strong>January 25:</strong> "Peak Demand Management in Commercial Buildings"</li><li><strong>February 8:</strong> "Battery Storage ROI Analysis and Optimization"</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'training-education'),
    'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44',
    FALSE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '11 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['webinar', 'education', 'energy-management', 'training'],
    'https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
),

(
    'Electric Vehicle Charging Infrastructure: Market Opportunities',
    'ev-charging-infrastructure-market-opportunities',
    'The rapid growth of electric vehicles is creating unprecedented opportunities in charging infrastructure development.',
    '<h2>EV Revolution Creates New Markets</h2><p>The electric vehicle market is experiencing explosive growth, with EV sales increasing 65% year-over-year. This growth is creating massive opportunities in charging infrastructure development.</p><h3>Market Statistics</h3><ul><li><strong>Current Market Size:</strong> $31 billion globally</li><li><strong>Projected 2030 Size:</strong> $165 billion</li></ul>',
    (SELECT id FROM public.news_categories WHERE slug = 'industry-updates'),
    NULL,
    TRUE,
    FALSE,
    TRUE,
    NOW() - INTERVAL '12 days',
    (SELECT id FROM auth.users ORDER BY created_at LIMIT 1),
    ARRAY['electric-vehicles', 'charging', 'infrastructure', 'market'],
    'https://images.unsplash.com/photo-1593941707882-a5bac6861d75?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'
);

-- Update view counts for realistic numbers
UPDATE public.news_articles SET view_count = 1250 WHERE slug = 'flow-platform-2-launch-revolutionary-changes';
UPDATE public.news_articles SET view_count = 890 WHERE slug = 'record-breaking-q4-results-clean-energy-growth';
UPDATE public.news_articles SET view_count = 670 WHERE slug = 'renewable-energy-market-trillion-globally';
UPDATE public.news_articles SET view_count = 445 WHERE slug = 'smart-grid-integration-future-energy-distribution';
UPDATE public.news_articles SET view_count = 320 WHERE slug = 'wind-energy-costs-drop-70-percent-decade';
UPDATE public.news_articles SET view_count = 280 WHERE slug = 'federal-tax-incentives-extended-2030';
UPDATE public.news_articles SET view_count = 195 WHERE slug = 'partnership-greentech-solutions-announcement';
UPDATE public.news_articles SET view_count = 150 WHERE slug = 'customer-success-manufacturing-90-percent-reduction';
UPDATE public.news_articles SET view_count = 125 WHERE slug = 'employee-spotlight-sarah-johnson-innovation-award';
UPDATE public.news_articles SET view_count = 98 WHERE slug = 'webinar-series-advanced-energy-management';