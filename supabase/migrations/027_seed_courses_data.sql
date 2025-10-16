-- Seed data for courses system with proper UUIDs
-- Note: Replace the company_id and created_by UUIDs with actual values from your system

-- Create variables for reusable UUIDs
DO $$
DECLARE
    demo_company_id UUID := '550e8400-e29b-41d4-a716-446655440000';
    demo_user_id UUID := '550e8400-e29b-41d4-a716-446655440001';

    -- Course IDs
    course1_id UUID := gen_random_uuid();
    course2_id UUID := gen_random_uuid();
    course3_id UUID := gen_random_uuid();
    course4_id UUID := gen_random_uuid();

    -- Lesson IDs for Course 1
    lesson1_1_id UUID := gen_random_uuid();
    lesson1_2_id UUID := gen_random_uuid();
    lesson1_3_id UUID := gen_random_uuid();
    lesson1_4_id UUID := gen_random_uuid();

    -- Lesson IDs for Course 2
    lesson2_1_id UUID := gen_random_uuid();
    lesson2_2_id UUID := gen_random_uuid();
    lesson2_3_id UUID := gen_random_uuid();
    lesson2_4_id UUID := gen_random_uuid();

    -- Lesson IDs for Course 3
    lesson3_1_id UUID := gen_random_uuid();
    lesson3_2_id UUID := gen_random_uuid();
    lesson3_3_id UUID := gen_random_uuid();
    lesson3_4_id UUID := gen_random_uuid();

    -- Lesson IDs for Course 4
    lesson4_1_id UUID := gen_random_uuid();
    lesson4_2_id UUID := gen_random_uuid();
    lesson4_3_id UUID := gen_random_uuid();
    lesson4_4_id UUID := gen_random_uuid();

    -- Exam IDs
    exam1_id UUID := gen_random_uuid();
    exam2_id UUID := gen_random_uuid();
    exam3_id UUID := gen_random_uuid();
    exam4_id UUID := gen_random_uuid();

BEGIN
    -- Insert sample courses
    INSERT INTO courses (id, title, description, thumbnail_url, difficulty_level, duration_hours, is_published, is_featured, category, tags, company_id, created_by) VALUES
    (
        course1_id,
        'Introduction to Solar Energy Systems',
        'Learn the fundamentals of solar energy systems, from basic photovoltaic principles to system design and installation. This comprehensive course covers everything you need to know to get started in the solar industry.',
        'https://images.unsplash.com/photo-1508615070457-7baeba4003ab?w=800&h=400&fit=crop',
        'beginner',
        8,
        true,
        true,
        'Technology',
        ARRAY['solar', 'renewable energy', 'photovoltaic', 'green technology'],
        demo_company_id,
        demo_user_id
    ),
    (
        course2_id,
        'Advanced Sales Techniques for Energy Consultants',
        'Master the art of consultative selling in the energy sector. Learn how to identify customer needs, overcome objections, and close deals effectively while building long-term relationships.',
        'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=400&fit=crop',
        'intermediate',
        12,
        true,
        true,
        'Business',
        ARRAY['sales', 'consulting', 'energy', 'customer relations'],
        demo_company_id,
        demo_user_id
    ),
    (
        course3_id,
        'Energy Efficiency Assessment and Auditing',
        'Develop expertise in conducting comprehensive energy audits for residential and commercial properties. Learn to use professional tools and create actionable efficiency improvement plans.',
        'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800&h=400&fit=crop',
        'advanced',
        15,
        true,
        false,
        'Technology',
        ARRAY['energy audit', 'efficiency', 'assessment', 'commercial', 'residential'],
        demo_company_id,
        demo_user_id
    ),
    (
        course4_id,
        'Digital Marketing for Energy Companies',
        'Explore modern digital marketing strategies specifically tailored for energy and sustainability companies. Learn SEO, social media marketing, content creation, and lead generation techniques.',
        'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=400&fit=crop',
        'intermediate',
        10,
        true,
        false,
        'Marketing',
        ARRAY['digital marketing', 'SEO', 'social media', 'lead generation', 'content marketing'],
        demo_company_id,
        demo_user_id
    );

    -- Insert lessons for Course 1: Introduction to Solar Energy Systems
    INSERT INTO lessons (id, course_id, title, description, content, lesson_order, duration_minutes, is_published) VALUES
    (
        lesson1_1_id,
        course1_id,
        'Solar Energy Fundamentals',
        'Understanding the basics of solar energy and photovoltaic technology',
        'Solar energy is the radiant light and heat from the Sun that has been harnessed by humans since ancient times. In this lesson, we will explore:

# What is Solar Energy?

Solar energy is electromagnetic radiation given off by the sun. Solar panels capture this energy and convert it into electricity through the photovoltaic effect.

## Key Concepts:

### Photovoltaic Effect
The photovoltaic effect is the creation of voltage or electric current in a material upon exposure to light. This is the fundamental principle behind solar panels.

### Types of Solar Cells
1. **Monocrystalline** - High efficiency, premium cost
2. **Polycrystalline** - Good efficiency, moderate cost
3. **Thin-film** - Lower efficiency, lowest cost

### Solar Irradiance
Solar irradiance is the power per unit area received from the Sun. It varies by:
- Geographic location
- Time of day
- Season
- Weather conditions

Understanding these fundamentals is crucial for anyone entering the solar industry.',
        1,
        45,
        true
    ),
    (
        lesson1_2_id,
        course1_id,
        'Solar Panel Types and Selection',
        'Learn about different types of solar panels and how to choose the right one',
        'Choosing the right solar panel is crucial for system performance and cost-effectiveness.

# Solar Panel Technologies

## Monocrystalline Solar Panels
- **Efficiency**: 15-22%
- **Lifespan**: 25-30 years
- **Best for**: Limited roof space, maximum efficiency needed
- **Cost**: Highest upfront cost, best long-term value

## Polycrystalline Solar Panels
- **Efficiency**: 13-16%
- **Lifespan**: 25-30 years
- **Best for**: Large installations, budget-conscious projects
- **Cost**: Moderate upfront cost, good value

## Thin-Film Solar Panels
- **Efficiency**: 10-12%
- **Lifespan**: 20-25 years
- **Best for**: Flexible applications, building-integrated PV
- **Cost**: Lowest upfront cost, requires more space

# Selection Criteria

When selecting panels, consider:
1. Available space
2. Budget constraints
3. Efficiency requirements
4. Aesthetic preferences
5. Local climate conditions
6. Warranty terms

The right choice depends on balancing these factors for each specific project.',
        2,
        50,
        true
    ),
    (
        lesson1_3_id,
        course1_id,
        'System Components and Design',
        'Overview of solar system components and basic design principles',
        'A complete solar energy system consists of several key components working together.

# Essential System Components

## Solar Panels (PV Modules)
The heart of the system that converts sunlight into DC electricity.

## Inverters
Convert DC electricity from panels into AC electricity for use in homes and businesses.

### Types of Inverters:
1. **String Inverters** - Cost-effective, suitable for unshaded roofs
2. **Power Optimizers** - Module-level optimization with string inverter
3. **Microinverters** - Individual panel optimization, best for complex installations

## Mounting Systems
Secure panels to roofs or ground-mount structures while maintaining proper orientation.

## Monitoring Systems
Track system performance and identify issues quickly.

## Safety Equipment
- DC and AC disconnect switches
- Grounding equipment
- Surge protection devices

# Basic Design Principles

## Optimal Orientation
- **Azimuth**: South-facing is ideal in Northern Hemisphere
- **Tilt angle**: Typically equals latitude for year-round optimization

## Shading Analysis
Even partial shading can significantly impact system performance.

## Load Analysis
Understanding energy consumption patterns helps size the system appropriately.

Proper system design ensures maximum energy production and return on investment.',
        3,
        55,
        true
    ),
    (
        lesson1_4_id,
        course1_id,
        'Installation and Maintenance Best Practices',
        'Learn proper installation techniques and ongoing maintenance requirements',
        'Proper installation and maintenance are critical for system longevity and performance.

# Installation Best Practices

## Site Assessment
- Structural integrity evaluation
- Electrical system compatibility
- Permits and code compliance
- Utility interconnection requirements

## Safety First
- Fall protection equipment
- Electrical safety procedures
- Proper tool usage
- Team communication protocols

## Installation Steps
1. **Roof preparation** - Marking layout, checking for obstacles
2. **Mounting installation** - Securing rails and attachments
3. **Panel installation** - Proper handling and securing
4. **Electrical connections** - DC wiring, grounding, inverter connection
5. **System commissioning** - Testing and documentation

# Maintenance Requirements

## Regular Inspections
- Visual inspection of panels and mounting
- Checking electrical connections
- Monitoring system performance
- Cleaning when necessary

## Performance Monitoring
- Daily production monitoring
- Comparing to expected output
- Identifying performance issues early

## Professional Maintenance
- Annual professional inspections
- Inverter maintenance/replacement
- Warranty compliance

## Common Issues
- Soiling and debris accumulation
- Shading from vegetation growth
- Electrical connection deterioration
- Inverter failures

A well-maintained system can operate efficiently for 25+ years with minimal issues.',
        4,
        60,
        true
    );

    -- Insert lesson resources for Course 1 lessons
    INSERT INTO lesson_resources (lesson_id, title, resource_type, url, duration_seconds, resource_order) VALUES
    -- Lesson 1 resources
    (lesson1_1_id, 'Solar Energy Basics Video', 'video', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4', 600, 1),
    (lesson1_1_id, 'Photovoltaic Effect Demonstration', 'video', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4', 480, 2),
    (lesson1_1_id, 'Solar Energy Fundamentals PDF', 'document', 'https://www.nrel.gov/docs/fy19osti/73495.pdf', null, 3),
    (lesson1_1_id, 'Solar Power World Magazine', 'link', 'https://www.solarpowerworldonline.com/', null, 4),

    -- Lesson 2 resources
    (lesson1_2_id, 'Panel Types Comparison', 'video', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4', 720, 1),
    (lesson1_2_id, 'Panel Selection Guide', 'document', 'https://www.energy.gov/sites/prod/files/2019/01/f58/74322.pdf', null, 2),
    (lesson1_2_id, 'Manufacturer Comparison Tool', 'link', 'https://www.energysage.com/solar/solar-panels/', null, 3),

    -- Lesson 3 resources
    (lesson1_3_id, 'System Design Walkthrough', 'video', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4', 900, 1),
    (lesson1_3_id, 'Inverter Technologies Explained', 'video', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4', 540, 2),
    (lesson1_3_id, 'PV System Design Guidelines', 'document', 'https://www.nrel.gov/docs/fy17osti/68690.pdf', null, 3),

    -- Lesson 4 resources
    (lesson1_4_id, 'Installation Safety Video', 'video', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4', 660, 1),
    (lesson1_4_id, 'Maintenance Best Practices', 'video', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4', 780, 2),
    (lesson1_4_id, 'Installation Manual Template', 'document', 'https://www.seia.org/sites/default/files/inline-files/BPG-Installation-Final.pdf', null, 3);

    -- Insert sample exams for courses
    INSERT INTO exams (id, course_id, title, description, instructions, time_limit_minutes, passing_score, max_attempts, randomize_questions, is_published) VALUES
    (
        exam1_id,
        course1_id,
        'Solar Energy Systems Certification Exam',
        'Test your knowledge of solar energy fundamentals, panel types, system design, and installation practices.',
        'This exam covers all material from the Introduction to Solar Energy Systems course. You have 60 minutes to complete 20 questions. A score of 80% or higher is required to pass. You may take this exam up to 3 times.',
        60,
        80,
        3,
        true,
        true
    ),
    (
        exam2_id,
        course2_id,
        'Advanced Sales Techniques Assessment',
        'Demonstrate your mastery of consultative selling, objection handling, and relationship building techniques.',
        'This exam tests your understanding of advanced sales methodologies specific to energy consulting. Answer all questions based on the course material. Passing score is 75%.',
        45,
        75,
        3,
        true,
        true
    );

    -- Sample exam questions for Course 1 (Solar Energy)
    INSERT INTO exam_questions (id, exam_id, question_text, question_type, options, correct_answer, points, explanation, question_order) VALUES
    (
        gen_random_uuid(),
        exam1_id,
        'What is the photovoltaic effect?',
        'multiple_choice',
        '{"a": "The heating of materials by sunlight", "b": "The creation of voltage or electric current in a material upon exposure to light", "c": "The reflection of light from solar panel surfaces", "d": "The absorption of heat by photovoltaic cells"}',
        '["b"]',
        5,
        'The photovoltaic effect is the fundamental principle behind solar panels, where certain materials generate electricity when exposed to light.',
        1
    ),
    (
        gen_random_uuid(),
        exam1_id,
        'Which type of solar panel typically has the highest efficiency?',
        'multiple_choice',
        '{"a": "Polycrystalline", "b": "Thin-film", "c": "Monocrystalline", "d": "Amorphous silicon"}',
        '["c"]',
        5,
        'Monocrystalline solar panels typically offer the highest efficiency rates, ranging from 15-22%.',
        2
    ),
    (
        gen_random_uuid(),
        exam1_id,
        'Solar panels convert DC electricity to AC electricity.',
        'true_false',
        null,
        '["false"]',
        5,
        'Solar panels generate DC electricity. Inverters are needed to convert DC to AC electricity for use in homes and businesses.',
        3
    ),
    (
        gen_random_uuid(),
        exam1_id,
        'What is the optimal orientation for solar panels in the Northern Hemisphere?',
        'short_answer',
        null,
        '["south"]',
        5,
        'South-facing orientation captures the most sunlight throughout the day in the Northern Hemisphere.',
        4
    );

    -- Sample exam questions for Course 2 (Sales)
    INSERT INTO exam_questions (id, exam_id, question_text, question_type, options, correct_answer, points, explanation, question_order) VALUES
    (
        gen_random_uuid(),
        exam2_id,
        'What is the primary goal of consultative selling?',
        'multiple_choice',
        '{"a": "To sell as much as possible", "b": "To understand customer needs and provide tailored solutions", "c": "To close deals quickly", "d": "To present all available products"}',
        '["b"]',
        5,
        'Consultative selling focuses on understanding customer needs first, then providing solutions that specifically address those needs.',
        1
    ),
    (
        gen_random_uuid(),
        exam2_id,
        'Which technique is most effective for handling price objections?',
        'multiple_choice',
        '{"a": "Immediately lower the price", "b": "Use the HEAR method: Halt, Empathize, Ask, Respond", "c": "Ignore the objection", "d": "Argue about the value"}',
        '["b"]',
        5,
        'The HEAR method provides a structured approach to understanding and addressing objections effectively.',
        2
    );

    RAISE NOTICE 'Seed data inserted successfully. Course 1 ID: %, Course 2 ID: %', course1_id, course2_id;

END $$;